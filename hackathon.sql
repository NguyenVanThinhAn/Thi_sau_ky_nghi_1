SET SQL_SAFE_UPDATES = 0;
DROP DATABASE test;
CREATE DATABASE test;

USE test;

CREATE TABLE Games(
	game_id varchar(5) primary key not null,
    game_name varchar(100) not null,
    genre varchar(50) not null,
    developer varchar(100) not null
);

CREATE TABLE Matches(
	match_id varchar(5) primary key not null,
    game_id varchar(5) not null,
    arena_name varchar(50) not null,
    start_time datetime not null,
    entry_fee decimal(10,2) not null check(entry_fee >= 0),
    FOREIGN KEY (game_id) REFERENCES Games(game_id)
);

CREATE TABLE Players(
	player_id varchar(5) primary key not null,
    nickname varchar(100) not null,
    email varchar(100) not null unique,
    rank_level varchar(50) not null check(rank_level = "Bạc" or rank_level =  "Vàng" or rank_level =  "Cao Thủ" or rank_level =  "Legendary") -- thêm legendary vì đề bài yêu cầu
);

CREATE TABLE Registrations(
	reg_id int primary key not null auto_increment,
    match_id varchar(5),
    player_id varchar(5),
    team_name varchar(50),
    status varchar(20) check( status = 'Confirmed' or status = 'Pending'or status = 'Canceled') default "Pending",
    FOREIGN KEY (match_id) REFERENCES Matches(match_id),
    FOREIGN KEY (player_id) REFERENCES Players(player_id)
);

-- insert games
INSERT INTO Games (game_id, game_name, genre, developer) 
VALUES
('G01', 'League of Legends', 'MOBA', 'Riot'),
('G02', 'Valorant', 'FPS', 'Riot'),
('G03', 'DOTA 2', 'MOBA', 'Valve'),
('G04', 'CS2', 'FPS', 'Valve');

-- insert match
INSERT INTO Matches (match_id, game_id, arena_name, start_time, entry_fee)
VALUES
('S01', 'G01', 'Stadium A','2025-11-10 18:00:00', 500000.00),
('S02','G02','Studio B','2025-11-10 20:00:00',300000.00),
('S03','G03','Stadium A','2025-11-11 09:00:00',200000.00),
('S04','G04','Online Server','2025-11-12 14:00:00',150000.00),
('S05','G04','Online Server','2025-11-12 14:00:00',0); -- thêm trận đấu entry_fee = 0

-- insert player
INSERT INTO Players (player_id, nickname, email, rank_level)
VALUES
('P01', 'Faker', 'faker@t1.com','Cao Thủ'),
('P02', 'TenZ', 'tenz@sentinels.com','Vàng'),
('P03', 'S1mple', 'simple@navi.com', 'Bạc');

INSERT INTO Registrations (match_id, player_id, team_name, status)
VALUES
('S01', 'P01', 'T1', 'Confirmed'),
('S02', 'P02', 'Sentinels', 'Confirmed'),
('S01', 'P03', 'NAVI', 'Canceled'),
('S04', 'P01', 'T1', 'Confirmed'),
('S03', 'P02', 'MixTeam', 'Pending'),
('S05', 'P02', 'MixTeam', 'Pending'); -- trận đấu bị xóa

-- update

UPDATE Matches SET entry_fee = entry_fee * 1.15 WHERE (match_id = 'S01');
UPDATE Players SET rank_level = 'Legendary' WHERE (player_id = 'P01');
DELETE FROM Registrations WHERE status = "Canceled";

ALTER TABLE Players
ADD COLUMN nationality varchar(50);

-- truy vấn

-- Liệt kê các trò chơi thuộc thể loại 'MOBA'.
SELECT *
FROM Games
WHERE genre = "MOBA";

-- Lấy thông tin nickname, email của những người chơi có tên chứa ký tự 'e'.
SELECT nickname,email
FROM Players
WHERE nickname LIKE("%e%");

-- Hiển thị danh sách các trận đấu gồm match_id, arena_name, start_time, sắp xếp theo start_time giảm dần.
SELECT match_id,arena_name,start_time
FROM Matches
ORDER BY start_time DESC;

-- Lấy ra 3 trận đấu có lệ phí (entry_fee) thấp nhất
SELECT *
FROM Matches
ORDER BY entry_fee
LIMIT 3;

-- Hiển thị game_name, genre từ bảng Games, bỏ qua game đầu tiên và lấy 2 game tiếp theo.
SELECT game_name, genre
FROM Games
LIMIT 2
OFFSET 1;

-- Giảm 20% lệ phí (entry_fee) cho tất cả các trận đấu diễn ra tại 'Online Server'.
SELECT arena_name, entry_fee * 0.8
FROM Matches
WHERE arena_name = "Online Server";

-- Chuyển đổi toàn bộ nickname của người chơi trong bảng Players thành chữ in hoa
SELECT upper(nickname)
FROM Players;

-- Xóa tất cả các trận đấu (Matches) có lệ phí (entry_fee) bằng 0 (nếu có) và đảm bảo các bản ghi liên quan trong bảng Registrations cũng được xử lý (lưu ý về ràng buộc khóa ngoại).
DELETE FROM Registrations reg WHERE reg.match_id IN (
	SELECT match_id
    FROM Matches mat
    WHERE mat.entry_fee <= 0
);

DELETE FROM Matches WHERE entry_fee <= 0;

-- Hiển thị danh sách: reg_id, nickname, game_name và team_name của các đơn đăng ký có trạng thái 'Confirmed'.
SELECT reg_id,nickname,game_name,team_name
FROM Registrations reg
JOIN Players pla ON pla.player_id = reg.player_id
JOIN Matches mat ON mat.match_id = reg.match_id
JOIN Games gam ON gam.game_id = mat.game_id
WHERE reg.status = "Confirmed"
GROUP BY reg_id;

-- Liệt kê tất cả trò chơi (Games) và thời gian thi đấu (start_time) tương ứng. Hiển thị cả những game chưa có trận đấu nào được xếp lịch.
SELECT game_name,start_time
FROM Games gam
RIGHT JOIN Matches mat ON mat.game_id = gam.game_id;

-- Tính tổng số đơn đăng ký theo từng trạng thái (status).
SELECT reg.status, COUNT(reg.status)
FROM Registrations reg
GROUP BY status;

-- Lấy thông tin các trận đấu có lệ phí thấp hơn lệ phí trung bình của tất cả các trận.
SELECT *
FROM Matches mat
WHERE mat.entry_fee < (
	SELECT AVG(mat2.entry_fee)
	FROM Matches mat2
);

-- Hiển thị nickname và rank_level của những người chơi đã đăng ký tham gia game 'League of Legends'.
SELECT pla.nickname ,pla.rank_level
FROM Players pla
JOIN Registrations reg ON reg.player_id = pla.player_id
JOIN Matches mat ON mat.match_id = reg.match_id
WHERE mat.game_id = "G01"
GROUP BY pla.nickname,pla.rank_level;

-- Liệt kê danh sách các trận đấu diễn ra trong tháng 11 năm 2025.
SELECT *
FROM Matches
WHERE year(start_time) = 2025 AND month(start_time) = 11;