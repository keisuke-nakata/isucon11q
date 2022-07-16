ALTER TABLE `isu_condition` ADD `rev_timestamp` INT AS (TIMESTAMPDIFF(SECOND, `timestamp`, '2050-01-01 00:00:00')) PERSISTENT;
ALTER TABLE `isu_condition` ADD INDEX `jia_isu_uuid_rev_timestamp_idx` (`jia_isu_uuid`, `rev_timestamp` DESC);
