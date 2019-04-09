function love.load()
  sprites = {}
 sprites.player = love.graphics.newImage('sprites/player.png')
 sprites.background = love.graphics.newImage('sprites/background.png')
 sprites.zombie = love.graphics.newImage('sprites/zombie.png')
 sprites.bullet = love.graphics.newImage('sprites/bullet.png')

 player = {}
 player.x = 1024/2
 player.y = 768/2
 player.speed = 180
 player.dead = false
 --- добавим таблицы для зомби
 zombies = {}
 bullets = {}

end
-- ====================================================
function love.update(dt)

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
  if love.keyboard.isDown("escape") then
    player.dead = true
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
 ---- удалим убитых зомби из таблицы
for i = #zombies, 1, -1 do
  local z = zombies[i]
    if player.dead == true or z.dead == true then
      table.remove(zombies, i)
    end
end
  --- проверяем догнал ли зомби игрока
  for i,z in ipairs(zombies) do
    for j,b in ipairs(bullets) do
        if distanceBetween(z.x, z.y, b.x, b.y) < 20 then
          z.dead = true
          b.dead = true
        end
    end
  end



end
--==================================================================
function love.draw()
  love.graphics.draw(sprites.background, 0, 0) -- обратите внимание что бэкграунд выводится первым
  --- добавляем возможность поворота игрока в сторону мыши
  if player.dead == false then -- есил игорок жив то рисуем
   love.graphics.draw(sprites.player, player.x, player.y, player_mouse_angle(), nil, nil, sprites.player:getWidth()/2, sprites.player:getHeight()/2  )
 else -- если мертв то надо выразить соболезнования
    -- где-то здесь
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
     if key =="space" then
        spawnZombie()
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

------ ф. стрельбы по нажатию левой кнопки мыши ---
function love.mousepressed(x, y, b, istoch)
  if b == 1 then
      spawnBullet()
    end

end
