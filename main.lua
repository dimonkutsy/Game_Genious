-- TODO или что можно добавить:
--  1. Добавить возможность "добывать" патроны
--  2. Меню
--  3. Стадии игры
--  4. GUI
--  5. Сложности игры
--  6. Разный урон
--  7. Разное оружие
--

function love.load()
  -- создание спрайтов к игре
  sprites = {}
  sprites.player = love.graphics.newImage('sprites/player.png')
  sprites.background = love.graphics.newImage('sprites/background.png')
  sprites.zombie = love.graphics.newImage('sprites/zombie.png')
  sprites.bullet = love.graphics.newImage('sprites/bullet.png')

  -- Получаем размеры окна
  width = love.graphics.getWidth()
  height = love.graphics.getHeight()
  -- создадим настройки для игрока
  player = {}
  player.x = width/2
  player.y = height/2
  player.speed = 180
  player.dead = false
  -- добавим таблицы для зомби
  zombies = {}
  bullets = {}
 -- Переменная для авто-спавна зомби
 spawntimer = 1
 --
 score = 0 -- Счёт
 bullets_amount = 10 -- Кол-во пуль по умолчанию
 -- Создание своего шрифта (в нашем случае только изменение размера)
 game_over = love.graphics.newFont(25)

end

function love.update(dt)
  -- Авто-спавн зомби
  spawntimer = spawntimer - dt
  if spawntimer <= 0 then
    spawnZombie()
    local leftover = math.abs(spawntimer)
    spawntimer = 1 - leftover
  end

  if love.keyboard.isDown("s") then
    player.y = player.y + player.speed * dt
  end
  if love.keyboard.isDown("w") then
    player.y = player.y - player.speed * dt
  end
  if love.keyboard.isDown("a") then
    player.x = player.x - player.speed * dt
  end
  if love.keyboard.isDown("d") then
    player.x = player.x + player.speed * dt
  end

  ---- проверяем расстояние между зомби и игроком и если оно меньше 20 - убиваем игрока и зомби
  for i,z in ipairs(zombies) do
    z.x = z.x + math.cos(zombie_player_angle(z)) * z.speed * dt
    z.y = z.y + math.sin(zombie_player_angle(z)) * z.speed * dt
        if distanceBetween(z.x, z.y, player.x, player.y) < 30 then
            for i,z in ipairs(zombies) do
              zombies[i].dead = true
            end
            player.dead = true
      end
  end

  ---- полет пули к цели ---
  for i,b in ipairs(bullets) do
     b.x = b.x + math.cos(b.direction) * b.speed * dt
     b.y = b.y + math.sin(b.direction) * b.speed * dt

  end

  --- обойдем таблицу с пулями и удалим те пули координаты которых вышли
  -- за пределы игрового экрана
 for i = #bullets, 1, -1 do
   local b = bullets[i]
   if  player.dead == true or b.x <0 or b.y < 0 or b.x > love.graphics:getWidth() or b.y > love.graphics.getHeight() then
     table.remove(bullets, i)
   end
end
 -- удалим убитых зомби из таблицы
for i = #zombies, 1, -1 do
  local z = zombies[i]
    if player.dead == true or z.dead == true then
        -- Подсчёт убитых Ержанов (лежит в if из-за бага при смерти , можешь убрать чтоб чекнуть)
        if player.dead == false then
          score = score + 1
        end
      table.remove(zombies, i)
    end
end
  -- проверяем догнал ли зомби игрока
  for i,z in ipairs(zombies) do
    for j,b in ipairs(bullets) do
        if distanceBetween(z.x, z.y, b.x, b.y) < 20 then
          z.dead = true
          b.dead = true
        end
    end
  end
  -- TODO Блокировка выхода за границы экрана (Но это стоит улучшить ибо сделано на скорую руку)
  if player.x < 20 then
    player.x = 20
  elseif player.y < 20 then
    player.y = 20
  elseif player.y > 750 then
    player.y = 750
  elseif player.x > 1010 then
    player.x = 1010
  end

end

function love.draw()
  love.graphics.draw(sprites.background, 0, 0) -- обратите внимание что бэкграунд выводится первым
  --- добавляем возможность поворота игрока в сторону мыши
  if player.dead == false then -- есил игорок жив то рисуем
   love.graphics.draw(sprites.player, player.x, player.y, player_mouse_angle(), nil, nil, sprites.player:getWidth()/2, sprites.player:getHeight()/2  )
   love.graphics.print("Score:" .. score , 5 , 5) -- TODO Завернуть в игровую стадию (чтоб не горело постоянно)
   love.graphics.print("Bullets:" .. bullets_amount , 5 , 20) -- TODO Завернуть в игровую стадию (чтоб не горело постоянно)
  else -- если мертв то надо выразить соболезнования (выражаем.)
    love.graphics.setFont(game_over)
    love.graphics.print("Game Over , score: " .. score , width/2-90 , height/2) -- TODO Изменить способ определния середины экрана
    love.graphics.print("press Enter to restart", width/2-90 , height/2+50)
  end

  --- обойдем всю таблицу zombies и выведем на экран всех зомби, которые хранятся в ее зловещих недрах
  for i,z in ipairs(zombies) do
    love.graphics.draw(sprites.zombie, z.x, z.y, zombie_player_angle(z), nil, nil, sprites.zombie:getWidth()/2, sprites.zombie:getHeight()/2 )
  end
  ---- визуализируем пули
  for i,b in ipairs(bullets) do
    love.graphics.draw(sprites.bullet, b.x, b.y, nil, 0.5, 0.5, sprites.bullet:getWidth()/2, sprites.bullet:getHeight()/2   )
  end
end
--=================== функции =========================================
--- ф. вычсления угла, для разворота игрока в сторону курсора мыши
function player_mouse_angle()
     return math.atan2(player.y - love.mouse.getY(), player.x - love.mouse.getX()) + math.pi
  end

  --- ф. разворота зомби в сторону игрока
function zombie_player_angle(enemy)
     return math.atan2(player.y - enemy.y, player.x - enemy.x)
  end
  --- ф. генерация  одиночного зомби
  function spawnZombie()
    ---- рождаем зомби
    zombie = {}
    zombie.x = math.random(0, love.graphics:getWidth())
    zombie.y = math.random(0, love.graphics:getHeight())
    zombie.speed = 100
    zombie.dead = false
  -- и добавляем его в таблицу где хранятся параметры всех зомби
  table.insert(zombies, zombie)


 end
 --- ф. рождения зомби при нажатии на клавишу пробел
 function love.keypressed(key, scancosde, isrepeat)
   -- Выход из игры по клавише Escape
   if key == "escape" then
     love.event.quit()
   end
   -- Перезапуск игры по клавише Enter при смерти игрока (в будущем нужно сменить на проверку по GameState)
   if player.dead == true and key == "return" then
     love.event.quit("restart")
   end
   -- Перезарядка , детка :D (Разрешена только при 0 патронов)
   if key == "r" and bullets_amount == 0 then
     bullets_amount = 10
   end
 end
 ---- ф. вычисление расстояния между точками
 function distanceBetween(x1, y1, x2, y2)
  return math.sqrt((y2 - y1)^2 +  (x2 -x1)^2 )
end
--- ф. генерации пули для стрельбы по зомби --------
function spawnBullet()
    bullet = {}
    -- начальные координаты пули совпадают с коорд. игрока
    bullet.y = player.y --
    bullet.x = player.x
    bullet.speed = 500  -- скорость пули
    --- направление пули - там где находится курсор мыши

    bullet.direction = player_mouse_angle()
    bullet.dead = false
    table.insert(bullets, bullet)
end

-- ф. стрельбы по нажатию левой кнопки мыши и наличию патронов :)
function love.mousepressed(x, y, b, istoch)
  if b == 1 and bullets_amount >= 1 then
      bullets_amount = bullets_amount - 1
      spawnBullet()
    end
end
