-- ARGoS Lua script implementing the subsumption architecture

-- Define behavior layers
function AvoidObstacles()
    local prox = robot.proximity
    local left, right = 0, 0
    
    for i = 1, #prox do
        left = left + prox[i].value * math.cos(prox[i].angle)
        right = right + prox[i].value * math.sin(prox[i].angle)
    end
    
    if left > right then
        return 10, -10  -- Turn right
    elseif right > left then
        return -10, 10  -- Turn left
    else
        return 0, 0
    end
end

function SeekLight()
    local light = robot.light
    local left, right = 0, 0
    
    for i = 1, #light do
        left = left + light[i].value * math.cos(light[i].angle)
        right = right + light[i].value * math.sin(light[i].angle)
    end
    
    return left * 15, right * 15  -- Move towards light
end

function HaltIfAtTarget()
    local ground = robot.ground
    if ground[1].value < 0.1 then  -- Assuming black spot means value close to 0
        return 0, 0  -- Stop movement
    end
    return nil
end

function step()
    -- Do the functions in order based on priority
    local leftWheel, rightWheel = HaltIfAtTarget()
    if not leftWheel then
        leftWheel, rightWheel = AvoidObstacles()
        if leftWheel == 0 and rightWheel == 0 then
            leftWheel, rightWheel = SeekLight()
        end
    end
    
    -- Clamp velocities between -15 and 15
    leftWheel = math.max(-15, math.min(15, leftWheel))
    rightWheel = math.max(-15, math.min(15, rightWheel))
    
    robot.wheels.set_velocity(leftWheel, rightWheel)
end

function reset()
    robot.wheels.set_velocity(0, 0)
end

function destroy()
    -- Cleanup code if needed
end
