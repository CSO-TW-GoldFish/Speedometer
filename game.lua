Game.Rule.respawnable = true

sync_speed = {}
for i = 1, 24 do
	sync_speed[i] = Game.SyncValue.Create("speed" .. i)
	sync_speed[i].value = 0
end

function Game.Rule:OnPlayerAttack() return 0 end

function Game.Rule:OnPlayerSignal(player, signal)
	local speed = math.sqrt(player.velocity.x ^ 2 + player.velocity.y ^ 2)
	if sync_speed[player.index].value ~= speed then
		sync_speed[player.index].value = speed
	end
end