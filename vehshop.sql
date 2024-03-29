CREATE TABLE IF NOT EXISTS `vehicle_financing` (
    `vehicleId` int(11) NOT NULL,
    `balance` int(11) DEFAULT NULL,
    `paymentamount` int(11) DEFAULT NULL,
    `paymentsleft` int(11) DEFAULT NULL,
    `financetime` int(11) DEFAULT NULL,
    PRIMARY KEY (`vehicleId`),
    FOREIGN KEY `vehicleId` (`vehicleId`) REFERENCES `player_vehicles` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
)    ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
