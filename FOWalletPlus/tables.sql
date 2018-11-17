CREATE TABLE IF NOT EXISTS "TWallets" (
    "account" TEXT PRIMARY KEY NOT NULL DEFAULT '',
    "prompt" TEXT DEFAULT '',
    "pubKey" TEXT DEFAULT '',
    "password" TEXT DEFAULT '',
    "priKey" TEXT DEFAULT '',
    "role" TEXT DEFAULT 'active',
    "current" INTEGER DEFAULT 0,
    "backUp" INTEGER DEFAULT 0,
    "endPoint" TEXT DEFAULT '',
    "extends" TEXT DEFAULT ''
);
CREATE TABLE IF NOT EXISTS TAssets(
    'primary' INTEGER NOT NULL,
    belong TEXT DEFAULT '',
    contract TEXT DEFAULT '',
    hide INTEGER DEFAULT 1,
    quantity TEXT DEFAULT '',
    lockToken TEXT DEFAULT '',
    contractWallet TEXT DEFAULT '',
    isSmart INTEGER DEFAULT 0,
    symbol TEXT DEFAULT '',
    updateAt INTEGER DEFAULT '',
    PRIMARY KEY (belong, symbol, contract)
);
CREATE TABLE IF NOT EXISTS TTokens (
    connector_balance TEXT DEFAULT '',
    connector_weight TEXT DEFAULT '',
    issuer TEXT DEFAULT '',
    max_exchange TEXT DEFAULT '',
    max_supply TEXT DEFAULT '',
    reserve_connector_balance TEXT DEFAULT '',
    reserve_supply TEXT DEFAULT '',
    supply TEXT DEFAULT '',
    symbol TEXT DEFAULT '',
    PRIMARY KEY (symbol, issuer)
);
