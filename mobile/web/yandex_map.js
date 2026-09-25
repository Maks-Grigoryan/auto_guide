// Yandex Maps JS API 2.1 bridge for the Flutter web build.
//
// Dart talks to this file through dart:js_interop:
//   * core/map/map_init_web.dart              -> avtoMap.init(apiKey)
//   * parts_results/.../results_map_view_web  -> avtoMap.render/dispose
//
// The JS API script is injected here rather than hard-coded in index.html
// because the key arrives at build time via --dart-define=MAPKIT_API_KEY.
//
// VERSION: 2.1, not 3.0. Keys issued on the free "JavaScript API" plan are
// rejected by the /v3/ loader with 403 Invalid api key while /2.1/ serves the
// library normally. Do not "upgrade" the URL below without re-checking that
// the project's key is accepted by that version.
//
// COORDINATE ORDER: JS API 2.1 takes [latitude, longitude] — the SAME order as
// the mobile MapKit Point(latitude:, longitude:), and the REVERSE of JS API
// 3.0. Every coordinate literal below is [lat, lng].

(function () {
  'use strict';

  // Yerevan city centre — matches kYerevanLat/kYerevanLng in
  // lib/core/location/location_service.dart (RES-06 fallback).
  var YEREVAN = [40.1872, 44.5152];

  var EMPTY_ZOOM = 12;   // no vendors  -> city overview (D-02)
  var SINGLE_ZOOM = 15;  // one vendor  -> street level (D-02)

  var state = {
    ready: false,
    loading: null,
    maps: Object.create(null),
  };

  function loadScript(apiKey) {
    return new Promise(function (resolve, reject) {
      var script = document.createElement('script');
      script.src =
        'https://api-maps.yandex.ru/2.1/?apikey=' +
        encodeURIComponent(apiKey) +
        '&lang=ru_RU';
      script.async = true;
      script.onload = resolve;
      script.onerror = function () {
        reject(new Error('Yandex Maps JS API failed to load'));
      };
      document.head.appendChild(script);
    });
  }

  /**
   * Loads the JS API and resolves once ymaps is usable.
   * Resolves false — never rejects — so Dart can degrade to the list path.
   * @param {string} apiKey
   * @returns {Promise<boolean>}
   */
  function init(apiKey) {
    if (state.ready) return Promise.resolve(true);
    if (!apiKey) return Promise.resolve(false);

    if (!state.loading) {
      state.loading = loadScript(apiKey)
        .then(function () {
          // ymaps.ready() with no callback returns a promise in 2.1.
          return window.ymaps.ready();
        })
        .then(function () {
          state.ready = true;
          return true;
        });
    }

    return state.loading.catch(function (error) {
      console.warn('[avtoMap] init failed, falling back to list view', error);
      state.loading = null;
      return false;
    });
  }

  function createMap(container) {
    var map = new window.ymaps.Map(
      container,
      {
        center: YEREVAN,
        zoom: EMPTY_ZOOM,
        controls: ['zoomControl', 'geolocationControl'],
      },
      { suppressMapOpenBlock: true }
    );

    var entry = { map: map, placemarks: [], observer: null };

    // Flutter lays the platform view out AFTER the element is handed over, so
    // the map is routinely built while the container is still 0x0. The JS API
    // measures once at construction and keeps that size, leaving a map that is
    // present in the DOM but paints nothing — the black panel on the «Карта»
    // tab. Re-measuring on every resize is what makes it appear.
    if (typeof ResizeObserver === 'function') {
      entry.observer = new ResizeObserver(function () {
        if (!container.clientWidth || !container.clientHeight) return;
        try {
          map.container.fitToViewport();
        } catch (error) {
          // The map may already be destroyed mid-teardown; nothing to redraw.
        }
      });
      entry.observer.observe(container);
    }

    return entry;
  }

  /**
   * Amber placemark carrying the distance label.
   *
   * `islands#orangeStretchyIcon` widens to fit iconContent, which is how the
   * mobile view renders the distance under the pin (UI-SPEC: amber #F5A623
   * with #1C1F26 text).
   */
  function buildPlacemark(vendor, onClick) {
    var placemark = new window.ymaps.Placemark(
      [vendor.lat, vendor.lng], // [lat, lng] — see header
      { iconContent: vendor.label },
      { preset: 'islands#orangeStretchyIcon' }
    );
    placemark.events.add('click', onClick);
    return placemark;
  }

  function clearPlacemarks(entry) {
    entry.map.geoObjects.removeAll();
    entry.placemarks = [];
  }

  /**
   * Renders one marker per vendor and fits the camera (D-02).
   * @param {HTMLElement} container  div created by the Flutter platform view
   * @param {string} vendorsJson  [{lat:number, lng:number, label:string}, ...]
   * @param {function(number):void} onTap  receives the vendor's index
   */
  // Takes the container ELEMENT, not an id. Flutter mounts platform views
  // inside <flt-platform-view>, whose contents document.getElementById does not
  // reach — the lookup silently returned null, the map was never built, and the
  // «Карта» tab showed a black panel.
  function render(container, vendorsJson, onTap) {
    if (!state.ready) return;
    if (!container) return;

    var vendors;
    try {
      vendors = JSON.parse(vendorsJson);
    } catch (error) {
      console.warn('[avtoMap] bad vendor payload', error);
      return;
    }

    var entry = container.__avtoMapEntry;
    if (!entry) {
      entry = container.__avtoMapEntry = createMap(container);
    }
    clearPlacemarks(entry);

    // D-02: empty set -> Yerevan centre, zoom 12.
    if (vendors.length === 0) {
      entry.map.setCenter(YEREVAN, EMPTY_ZOOM);
      return;
    }

    var minLat = vendors[0].lat;
    var maxLat = vendors[0].lat;
    var minLng = vendors[0].lng;
    var maxLng = vendors[0].lng;

    for (var i = 0; i < vendors.length; i++) {
      var vendor = vendors[i];
      var placemark = buildPlacemark(
        vendor,
        (function (index) {
          return function () {
            onTap(index);
          };
        })(i)
      );
      entry.map.geoObjects.add(placemark);
      entry.placemarks.push(placemark);

      minLat = Math.min(minLat, vendor.lat);
      maxLat = Math.max(maxLat, vendor.lat);
      minLng = Math.min(minLng, vendor.lng);
      maxLng = Math.max(maxLng, vendor.lng);
    }

    // D-02: a single vendor degenerates the bounding box to a point, so centre
    // on it at street zoom instead of fitting bounds.
    if (vendors.length === 1) {
      entry.map.setCenter([vendors[0].lat, vendors[0].lng], SINGLE_ZOOM);
      return;
    }

    entry.map.setBounds(
      [
        [minLat, minLng], // south-west
        [maxLat, maxLng], // north-east
      ],
      { checkZoomRange: true, zoomMargin: 40 }
    );
  }

  /** Destroys the map bound to [container]. Safe to call twice. */
  function dispose(container) {
    if (!container) return;
    var entry = container.__avtoMapEntry;
    if (!entry) return;
    if (entry.observer) entry.observer.disconnect();
    clearPlacemarks(entry);
    entry.map.destroy();
    delete container.__avtoMapEntry;
  }

  window.avtoMap = { init: init, render: render, dispose: dispose };
})();
