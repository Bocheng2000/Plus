CREATE TABLE IF NOT EXISTS "TWallets" (
    "account" TEXT PRIMARY KEY NOT NULL DEFAULT '',
    "prompt" TEXT DEFAULT '',
    "pubKey" TEXT DEFAULT '',
    "password" TEXT DEFAULT '',
    "priKey" TEXT DEFAULT '',
    "role" TEXT DEFAULT 'active',
    "current" INTEGER DEFAULT 0,
    "extends" TEXT DEFAULT ''
);
