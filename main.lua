------------window dimensions---------------
window_width=1375
window_height=750
-------------character attributes------------
Player={}
Player.x=0
Player.y=360
Player.width=50
Player.height=50

math.randomseed(os.time())
function collision(v,k)
    return v.x<k.x+k.width and
           v.x+v.width>k.x and
           v.y<k.y+k.height and
           v.y+v.height>k.y
end
all_obstacles={}
function createObstacles()
    local obstacle={}
-----------obstacle deciding----------------
    r=math.random(1,3)
    if (r==1)then
        obstacle.width=150
        obstacle.height=75
    elseif(r==2)then
        obstacle.width=100
        obstacle.height=40
    else
        obstacle.width=170
        obstacle.height=70
    end
-----------obstacle attributes--------------
    obstacle.x=math.random(0,1000)
    obstacle.y=-obstacle.height
    obstacle.speed=200
    obstacle.body=world:newRectangleCollider(obstacle.x,obstacle.y,obstacle.width,obstacle.height)
    obstacle.body:setCollisionClass('platform')
    obstacle.body:setType('dynamic')
    return(obstacle)
end

   
function love.load()
    love.window.setMode(window_width,window_height)
    timer=0
    obstacle_timer=0
----------world generation---------------------------
    wf = require 'library/windfield-master/windfield'
    world = wf.newWorld(0,500,false)
    world:setQueryDebugDrawing(false)
-----------collision class---------------------------
    world:addCollisionClass('player')
    world:addCollisionClass('objects')
    world:addCollisionClass('platform')
----------character generation-----------------------
    player = world:newRectangleCollider(Player.x,Player.y,Player.width,Player.height)
    player:setFixedRotation(true)
    player.speed=200
    player.grounded=false
-----------platform generation-----------------------
    platform = world:newRectangleCollider(0,window_height,window_width+80,2,{collision_class='platform'})
    platform:setType('static')
    
    
    
   
end
function love.update(dt)
    world:update(dt)
    timer=timer+dt
    obstacle_timer=obstacle_timer+dt
    local x,y = player:getPosition()
-------------character movement---------------------
    if love.keyboard.isDown("d")then
        player:setX(x+player.speed*dt) 
    end

    if love.keyboard.isDown("a")then
        player:setX(x-player.speed*dt) 
    end
-------------character movement restriction---------
    if(player:setX<0) then
        Player.x=0
    end
    if(Player.x>window_width-Player.width) then
        Player.x=window_width-Player.width
    end

------------obstacles generation--------------------  
    if (obstacle_timer>2) then
        table.insert(all_obstacles,createObstacles())
        obstacle_timer=0
    end
    for k,v in pairs(all_obstacles) do 
        v.y=v.y+v.speed*dt
    end
    if(player.body) then
        local collider=world:queryRectangleArea(player:getX()-19,player:getY()+15,28,20,{'objects'})
        local collider2=world:queryRectangleArea(player:getX()-19,player:getY()+15,28,20,{"platform"})
        if(#collider>0)then
            player.grounded=true
        else
            player.grounded=false
        end
        if(#collider2>0)then
            player.grounded=true
        else
            player.grounded=false
        end
    end
end
function love.keypressed(key)
----------character jump----------------------------  
    if (key=="space" and player.grounded) then
        player:applyLinearImpulse(0,-1600)

    end
end
function love.draw()
    world:draw()
end