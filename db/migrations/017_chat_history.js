/**
 * Migration 017: assistant conversation history.
 *
 * WHY THIS EXISTS AT ALL: a language model has no memory. Every request carries
 * the whole conversation again, or the third message in a thread arrives with
 * no idea what the first two were about. So the history is not a feature — it
 * is what makes a second question possible. The only real choice is where it
 * lives, and process memory loses it on every deploy, splits it across
 * instances behind a load balancer, and makes the daily quota resettable by
 * anyone who waits for a restart.
 *
 * NOT GRANTED TO ai_readonly. Migration 015 lists its tables by name and these
 * are not among them: the assistant reads the catalogue, it does not get to
 * read what people have written to it.
 *
 * Token counts are stored per message so spend can be answered from the
 * database rather than guessed from an invoice at the end of the month.
 *
 * RETENTION: rows are meant to be deleted after 90 days. That job is not part
 * of this migration — a cron running a DELETE, or a pg_cron entry, added once
 * real conversations exist. The index on (conversation_id, created_at) serves
 * both that sweep and the daily quota count.
 */

exports.up = (pgm) => {
  pgm.sql(`
    CREATE TABLE chat_conversations (
        id         bigserial   PRIMARY KEY,
        user_id    bigint      NOT NULL REFERENCES users (id) ON DELETE CASCADE,
        created_at timestamptz NOT NULL DEFAULT now()
    );
  `);

  // Every listing is "this user's conversations, newest first".
  pgm.sql(`
    CREATE INDEX chat_conversations_user_recent
        ON chat_conversations (user_id, created_at DESC);
  `);

  pgm.sql(`
    CREATE TABLE chat_messages (
        id              bigserial   PRIMARY KEY,
        conversation_id bigint      NOT NULL
                                    REFERENCES chat_conversations (id) ON DELETE CASCADE,
        role            text        NOT NULL,
        content         text        NOT NULL,
        -- Part cards the SERVER attached from tool results. The model never
        -- writes links: what it cannot produce, it cannot invent.
        attachments     jsonb,
        input_tokens    integer,
        output_tokens   integer,
        created_at      timestamptz NOT NULL DEFAULT now(),

        CONSTRAINT chat_messages_role_valid
            CHECK (role IN ('user', 'assistant'))
    );
  `);

  // Reading a thread: every message of one conversation, in order.
  pgm.sql(`
    CREATE INDEX chat_messages_conversation_order
        ON chat_messages (conversation_id, created_at);
  `);

  // Daily quota: how many messages this user has sent since midnight. Partial
  // on 'user' because assistant replies never count against the quota.
  pgm.sql(`
    CREATE INDEX chat_messages_user_quota
        ON chat_messages (conversation_id, created_at)
        WHERE role = 'user';
  `);
};

exports.down = (pgm) => {
  // chat_messages first: it holds the foreign key.
  pgm.sql('DROP TABLE IF EXISTS chat_messages;');
  pgm.sql('DROP TABLE IF EXISTS chat_conversations;');
};
