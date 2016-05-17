BEGIN TRANSACTION;
CREATE TABLE User (
	id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
	nic varchar(255),
	karma double,
	rating double
);
CREATE TABLE "Post" (
	`id`	INTEGER NOT NULL,
	`author_id`	INTEGER NOT NULL,
	`post_name`	varchar(255),
	`post_rating`	INTEGER,
	`views`	INTEGER,
	`stars`	INTEGER,
	`owner_coments`	INTEGER,
	`coments_num`	INTEGER NOT NULL,
	PRIMARY KEY(id),
	FOREIGN KEY(`author_id`) REFERENCES `User`(`id`)
);
CREATE TABLE "Comments" (
id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
post_id INTEGER,
user_id INTEGER,
FOREIGN KEY(post_id) REFERENCES Post(id),
FOREIGN KEY(user_id) REFERENCES User(id)
);
COMMIT;

