-- HOW TO SETUP (You may need to replace user name which is "root" in below example)
-- 1. mysqladmin -u root -p create any_db_name
-- 2. mysql -u root any_db_name < handhq_db_setup.sql

CREATE TABLE rank (id int PRIMARY KEY, value int);
DELIMITER //
CREATE PROCEDURE gen_rank_data() BEGIN   set @counter = 1; while @counter <= 13 DO   INSERT INTO rank VALUES (@counter-1, @counter);   SET @counter = @counter + 1; END WHILE; END//
DELIMITER ;
CALL gen_rank_data();
DROP PROCEDURE gen_rank_data;

CREATE TABLE suit (id int PRIMARY KEY, name varchar(10));
INSERT INTO suit VALUES (2, "CLUB"), (4, "DIAMOND"), (8, "HEART"), (16, "SPADE");

CREATE TABLE card (id int PRIMARY KEY, rank_id int, suit_id int, FOREIGN KEY (rank_id) REFERENCES rank (id), FOREIGN KEY (suit_id) REFERENCES suit (id));
DELIMITER //
CREATE PROCEDURE gen_card_data() BEGIN   SET @id = 1;   WHILE @id <= 52 DO     SET @tmp = (@id-1) DIV 13+1;     SET @suit = 1 << @tmp;     SET @rank = @id - 13 * (@tmp-1)-1;     INSERT INTO card VALUES (@id, @rank, @suit); SET @id = @id + 1; END WHILE; END//
DELIMITER ;
CALL gen_card_data();
DROP PROCEDURE gen_card_data;

CREATE TABLE board (id int PRIMARY KEY AUTO_INCREMENT);
CREATE TABLE board_card_relation (id int PRIMARY KEY AUTO_INCREMENT, board_id int, card_id int, FOREIGN KEY(board_id) REFERENCES board(id) ON UPDATE CASCADE ON DELETE CASCADE, FOREIGN KEY(card_id) REFERENCES card(id));

CREATE TABLE street_name (id int PRIMARY KEY AUTO_INCREMENT, name varchar(15));
INSERT INTO street_name VALUES (1, "POCKET CARD"), (2, "FLOP"), (3, "TURN"), (4, "RIVER"), (5, "SHOWDOWN");

CREATE TABLE seat_result (id  int PRIMARY KEY AUTO_INCREMENT, player_id char(30), seat_position int);

CREATE TABLE lost_result (id int PRIMARY KEY AUTO_INCREMENT, seat_result_id int, detail text, FOREIGN KEY(seat_result_id) REFERENCES seat_result(id) ON UPDATE CASCADE ON DELETE CASCADE);
CREATE TABLE lost_hole_relation(id int PRIMARY KEY AUTO_INCREMENT, result_id int, card_id int, FOREIGN KEY(result_id) REFERENCES lost_result(id), FOREIGN KEY(card_id) REFERENCES card(id));

CREATE TABLE muck_result (id int PRIMARY KEY AUTO_INCREMENT, seat_result_id int, FOREIGN KEY(seat_result_id) REFERENCES seat_result(id) ON UPDATE CASCADE ON DELETE CASCADE);
CREATE TABLE muck_hole_relation (id int PRIMARY KEY AUTO_INCREMENT, result_id int, card_id int, FOREIGN KEY(result_id) REFERENCES muck_result(id), FOREIGN KEY(card_id) REFERENCES card(id));

CREATE TABLE win_result (id int PRIMARY KEY AUTO_INCREMENT, amount float, detail text, seat_result_id int, FOREIGN KEY(seat_result_id) REFERENCES seat_result(id) ON UPDATE CASCADE ON DELETE CASCADE);
CREATE TABLE win_hole_relation (id int PRIMARY KEY AUTO_INCREMENT, result_id int, card_id int, FOREIGN KEY(result_id) REFERENCES win_result(id), FOREIGN KEY(card_id) REFERENCES card(id));

CREATE TABLE folded_result (id int PRIMARY KEY AUTO_INCREMENT, street_type int, seat_result_id int, FOREIGN KEY (street_type) REFERENCES street_name(id), FOREIGN KEY(seat_result_id) REFERENCES seat_result(id) ON UPDATE CASCADE ON DELETE CASCADE);

CREATE TABLE collected_result (id int PRIMARY KEY AUTO_INCREMENT, amount float, seat_result_id int, FOREIGN KEY(seat_result_id) REFERENCES seat_result(id) ON UPDATE CASCADE ON DELETE CASCADE);

CREATE TABLE summary (id int PRIMARY KEY AUTO_INCREMENT, pot float, rake float, jackpot_rake float, board_id int, FOREIGN KEY (board_id) REFERENCES board(id) ON UPDATE CASCADE ON DELETE SET NULL);

CREATE TABLE summary_result_relation (id int PRIMARY KEY AUTO_INCREMENT, summary_id int, seat_result_id int, FOREIGN KEY(summary_id) REFERENCES summary(id) ON UPDATE CASCADE ON DELETE CASCADE, FOREIGN KEY(seat_result_id) REFERENCES seat_result(id) ON UPDATE CASCADE ON DELETE SET NULL);

CREATE TABLE action_name (id int PRIMARY KEY, name varchar(20));
INSERT INTO action_name VALUES (0, "ANTE"), (1, "SMALL BLIND"), (2, "BIG BLIND"), (3, "FOLD"), (4, "CHECK"), (5, "CALL"), (6, "RAISE"), (7, "BET"), (8, "ALLIN");

CREATE TABLE action (id int PRIMARY KEY AUTO_INCREMENT, player_id varchar(30), type int, bet_amount float, add_amount float, FOREIGN KEY(type) REFERENCES action_name(id));

CREATE TABLE street (id int PRIMARY KEY AUTO_INCREMENT, type int, board_id int, FOREIGN KEY(type) REFERENCES street_name(id), FOREIGN KEY(board_id) REFERENCES board(id) ON UPDATE CASCADE ON DELETE SET NULL);

CREATE TABLE street_action_relation (id int PRIMARY KEY AUTO_INCREMENT, street_id int, action_id int, FOREIGN KEY(street_id) REFERENCES street(id) ON UPDATE CASCADE ON DELETE CASCADE, FOREIGN KEY(action_id) REFERENCES action(id) ON UPDATE CASCADE ON DELETE CASCADE);

CREATE TABLE player_info (id int PRIMARY KEY AUTO_INCREMENT, player_id char(30), seat_position int, stack float, role ENUM("sb", "bb", "dealer"));

CREATE TABLE round (round_id char(15) PRIMARY KEY, play_time datetime, rule text, blind float, dealer_position int, table_name varchar(30), summary_id int, FOREIGN KEY(summary_id) REFERENCES summary(id) ON UPDATE CASCADE ON DELETE SET NULL);

CREATE TABLE round_playerinfo_relation (id int PRIMARY KEY AUTO_INCREMENT, round_id char(15), player_info_id int, FOREIGN KEY(round_id) REFERENCES round(round_id) ON UPDATE CASCADE ON DELETE CASCADE, FOREIGN KEY(player_info_id) REFERENCES player_info(id) ON UPDATE CASCADE ON DELETE CASCADE);

CREATE TABLE round_street_relation (id int PRIMARY KEY AUTO_INCREMENT, round_id char(15), street_id int, FOREIGN KEY(round_id) REFERENCES round(round_id) ON UPDATE CASCADE ON DELETE CASCADE, FOREIGN KEY(street_id) REFERENCES street(id) ON UPDATE CASCADE ON DELETE CASCADE);
