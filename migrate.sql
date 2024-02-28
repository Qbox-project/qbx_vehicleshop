CREATE TABLE IF NOT EXISTS `vehicle_financing` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `citizenid` varchar(50) DEFAULT NULL,
    `plate` varchar(15) NOT NULL,
    `balance` int(11) NOT NULL DEFAULT 0,
    `paymentamount` int(11) NOT NULL DEFAULT 0,
    `paymentsleft` int(11) NOT NULL DEFAULT 0,
    `financetime` int(11) NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`),
    FOREIGN KEY `plate` (`plate`) REFERENCES `player_vehicles` (`plate`) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY `citizenid` (`citizenid`) REFERENCES `players` (citizenid) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO vehicle_financing (citizenid, plate, balance, paymentamount, paymentsleft, financetime)
SELECT citizenid, plate, balance, paymentamount, paymentsleft, financetime
FROM player_vehicles
WHERE balance > 0 OR paymentamount > 0 OR paymentsleft > 0 OR financetime > 0;

ALTER TABLE player_vehicles
DROP COLUMN balance,
DROP COLUMN paymentamount,
DROP COLUMN paymentsleft,
DROP COLUMN financetime;