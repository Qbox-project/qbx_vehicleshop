CREATE TABLE IF NOT EXISTS `vehicle_financing` (
    `vehicleId` int(11) NOT NULL,
    `citizenid` varchar(50) NOT NULL,
    `plate` varchar(15) NOT NULL,
    `balance` int(11) DEFAULT NULL,
    `paymentamount` int(11) DEFAULT NULL,
    `paymentsleft` int(11) DEFAULT NULL,
    `financetime` int(11) DEFAULT NULL,
    PRIMARY KEY (`vehicleId`),
    FOREIGN KEY `vehicleId` (`vehicleId`) REFERENCES `player_vehicles` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY `plate` (`plate`) REFERENCES `player_vehicles` (`plate`) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY `citizenid` (`citizenid`) REFERENCES `players` (`citizenid`) ON DELETE CASCADE ON UPDATE CASCADE
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
