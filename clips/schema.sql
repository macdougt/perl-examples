
CREATE TABLE `tbl_clips` (
	`timestamp`	INTEGER NOT NULL UNIQUE,
	`application`	TEXT NOT NULL,
	`contents`	TEXT NOT NULL,
	`type`	TEXT NOT NULL,
	PRIMARY KEY(`timestamp`)
);
