DROP TABLE IF EXISTS spaceship_titanic_raw;
DROP TABLE IF EXISTS spaceship_titanic;

CREATE TABLE spaceship_titanic_raw (
  passengerid TEXT,
  homeplanet TEXT,
  cryosleep TEXT,
  cabin TEXT,
  destination TEXT,
  age TEXT,
  vip TEXT,
  roomservice TEXT,
  foodcourt TEXT,
  shoppingmall TEXT,
  spa TEXT,
  vrdeck TEXT,
  name TEXT,
  transported TEXT
);