require("global")
require("colors")

Map = {}
Map.zoom = 3
Map.root = {
    x = love.graphics.getWidth() / 2,
    y = love.graphics.getHeight() / 2
}

function Map.draw()
    local currentx, currenty = 0, 0

    love.graphics.setColor(1, 1, 1, .5)
    if KEYFRAME_LIST_GLOBAL ~= nil then
        local x, y = 0, 0
        local mostRecentKeyframe = nil
        local r = 0
        local hoveredFrame = nil

        for i = 1, currentFilm.totalFrames do
            local waited = true
            local isKeyframe = KEYFRAME_LIST_GLOBAL[i] ~= nil
            if isKeyframe then
                mostRecentKeyframe = KEYFRAME_LIST_GLOBAL[i]
            end

            local drawx, drawy = Map.root.x + Map.zoom * x, Map.root.y + Map.zoom * y

            if mostRecentKeyframe then
                if mostRecentKeyframe:hasState("up") then
                    y = y - 1
                    waited = false
                end
                if mostRecentKeyframe:hasState("down") then
                    y = y + 1
                    waited = false
                end
                if mostRecentKeyframe:hasState("left") then
                    x = x - 1
                    waited = false
                end
                if mostRecentKeyframe:hasState("right") then
                    x = x + 1
                    waited = false
                end

                if waited then
                    if r == 0 then
                        love.graphics.setColor(0, 1, 1)
                        love.graphics.circle("line", drawx, drawy, 3)
                    end
                    r = r + 1
                else
                    r = 0
                end

                love.graphics.setColor(0, 1, 1)
                if isKeyframe then
                    love.graphics.setColor(1, 1, 1)
                    love.graphics.rectangle("fill", drawx, drawy, 2, 2)
                end

                love.graphics.rectangle("fill", drawx, drawy, 1, 1)
            end

            if i == currentFilm.playhead then
                currentx = x
                currenty = y

                if MAP_LOCK then
                    Map.root.x = love.graphics.getWidth() / 2 - currentx * Map.zoom
                    Map.root.y = love.graphics.getHeight() / 2 - currenty * Map.zoom
                end
                love.graphics.setColor(0, 1, 0)
                love.graphics.circle("fill", drawx, drawy, 5)
                love.graphics.circle("line", drawx, drawy, 7)
                if waited then
                    local d = 15
                    love.graphics.circle("line", drawx, drawy, (math.sin(r / d) + 3) * 3)
                end
            end

            local mx, my = love.mouse.getPosition()

            if math.abs(mx - drawx) < 5 and math.abs(my - drawy) < 5 and hoveredFrame == nil then
                hoveredFrame = i
                love.graphics.circle("fill", drawx, drawy, 5)
                if love.mouse.isDown(1) then
                    currentFilm:movePlayheadTo(i)
                end
            end
        end

        if hoveredFrame then
            love.graphics.setColor(1, 1, 1, 0.75)
            if love.filesystem.exists(currentFilm.path .. "/" .. hoveredFrame .. ".png") then
                love.graphics.draw(love.graphics.newImage(currentFilm.path .. "/" .. hoveredFrame .. ".png"))
            else
                love.graphics.draw(love.graphics.newImage("noimage.png"))
            end
        end
    end

    love.graphics.setColor(1, 1, 1, 1)
end
