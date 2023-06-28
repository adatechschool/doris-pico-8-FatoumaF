pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
--aventure
--fatouma, jeremie, claire

function _init()	
	map_setup()
	make_player()
	make_enemy()
	spawn_balls()
--	add_balls()
	init_msg()
	
	blinkcol=7
	blinkframe=0
	blinkspeed=5
	
	state="menu"
end

function _update()
	blink()
	if state=="menu" then
		update_menu()
	elseif state=="game" then
		update_game()
	elseif state=="wingame" then
		update_wingame()
	elseif state=="loosegame" then
		update_loosegame()
	end
end

function _draw()
	if state=="menu" then
		draw_menu()
	elseif state=="game" then
		draw_game()
	elseif state=="wingame" then
		draw_wingame()
	elseif state=="loosegame" then
		draw_loosegame()
	end
end

-- menu
function update_menu()
	if (btnp(❎)) state="game"
end

function draw_menu()
	cls()
	print("press ❎ to start",25,60,blinkcol)
	spr(193,50,70)
	spr(194,58,70)
	spr(209,50,78)
	spr(210,58,78)

end

-- game
function update_game()
	update_map()
	update_camera()	
	if not messages[1] then
		move_player()
		move_enemy()
		move_balls()
	end
	clear_msg()
end

function draw_game()
	cls()
	draw_map()
	draw_enemy()
	draw_balls()
	--overlay(first)
	draw_player()
	draw_ui()
	draw_popup()
end

-- wingame
function update_wingame()
	camera()
	p.x=3
	p.y=3
	p.coin=0
	p.wood=0
	p.water=0
	p.life=3
	p.axe=false
	if (btnp(❎)) state="game"
end

function draw_wingame()
	cls()
	print("congratulations, you win !",10,60,10)
	spr(196,50,70)
	spr(197,58,70)
	spr(212,50,78)
	spr(213,58,78)
	print("press ❎ to start again",15,95,blinkcol)
end

-- loosegame
function update_loosegame()
	camera()
	p.x=3
	p.y=3
	p.coin=0
	p.wood=0
	p.water=0
	p.life=3
	p.axe=false
	if (btnp(❎)) state="game"
end

function draw_loosegame()
	cls()
	print("game over...",35,60,8)
	spr(199,50,70)
	spr(200,58,70)
	spr(215,50,78)
	spr(216,58,78)
	print("press ❎ to start again",15,95,blinkcol)
end
-->8
--map

function map_setup()

 --timers
    timer=0
    anim_time=30 --30 = 1 second

	wall=0
	interact=1
	lives=2
	anim1=4
	anim2=5
	loose=6
	win=7
end

function draw_map()
	map(0,0,0,0,128,64)
end

function update_map()
 if (timer<0) then
   toggle_tiles()
   flip_coins()
  	timer=anim_time
 end
timer-=1
end

function is_tile(tile_type,x,y)
	tile=mget(x,y)
	has_flag=fget(tile,tile_type)
	return has_flag
end

function can_move(x,y)
	return not is_tile(wall,x,y)
end

function update_camera()
	camx=flr(p.x/16)*16
	camy=mid(0,p.y-7.5,31-15)
	
	camera(camx*8,camy*8)
end

function next_tile(x,y)
	sprite=mget(x,y)
	mset(x,y,sprite+1)
end

function next_tile_def3(x,y)
	sprite=mget(x,y)
	mset(x,y,129)
end

--function overlay(first)
	--if first==true then
	--	for x=64,(64+16) do
			--for y=0,16 do
				
				--if not
				--((x>=p.x-1 and x<=p.x+1)
				--and
				--(y>=p.y-1 and y<=p.y+1))
				--then
				--spr(75,x*8,y*8,8,8)
				--end
				
			--end
		--end
	--end
--end

function get_wood(x,y)
	p.wood+=1
	next_tile(x,y)
end

function get_water(x,y)
	p.water+=1
	next_tile(x,y)
end

function build_bridge(x,y)
	p.wood-=1
	next_tile(x,y)
end 

function get_coin(x,y)
	p.coin+=1
	next_tile_def3(x,y)
	
end

function talking_fox(x,y)
	color=9
	next_tile(x,y)
	next_tile(x,y-1)
	create_msg("fox","help !\nthe bridge is broken.", "if you find an axe and cut\nsome wood, you can rebuild it.")
	msg="pnj"
end

function talking_cactus(x,y)
	color=11
	next_tile(x,y)
	next_tile(x,y-1)
	create_msg("cactus","be careful with the fireballs,\nyou can kill them with water !")
	msg="pnj"
end

function enter_volcano(x,y)
		next_tile(x,y)
		msg="pnj"
		color=8
		create_msg("belzebuth","welcome to my lair,\ncome in if you dare...","if you can find 5 gold coins,\nyou won't get destroyed.")
		visited_volcano=true
end

function chest(x,y)
	next_tile(x,y)
	create_msg("you found an axe!","press ❎ to close")
	p.axe=true
	sfx(0)
	msg="popup"
end

function iswater(x,y)
	if mget(x,y)==32 or mget(x,y)==34 or mget(x,y)==36
	then
	return true 
	end
end

function iscoin(x,y)
	if mget(x,y)==144 or mget(x,y)==145
	then
	return true
	end
end

function level()
	if flr(p.x/16)==0 or flr(p.x/16)==1 then
			return 1
	elseif flr(p.x/16)==2 or flr(p.x/16)==3 then
			return 2
	elseif flr(p.x/16)==4 or flr(p.x/16)==5 then
			return 3	
	end
end

function blink(color)
	blinkframe+=1
	if blinkframe>blinkspeed then
		blinkframe=0
		if blinkcol==7 then
			blinkcol=color
		else
			blinkcol=7
		end
	end
end
-->8
--player

function make_player()
	p={
		x=33,
		y=7,
		sprite=1,
		wood=0,
		water=0,
		coin=0,
		life=3
	}
end

function draw_player()
	spr(p.sprite,p.x*8,p.y*8,1,1,p.flip)
end

function move_player()
	newx=p.x
	newy=p.y

	if btnp(⬅️) then
		newx-=1
		p.flip=true
	elseif btnp(➡️) then
		newx+=1
		p.flip=false
	elseif btnp(⬆️) then
		newy-=1
	elseif btnp(⬇️) then
		newy+=1
	end
	
	f_interact(newx,newy)
	
	if (can_move(newx,newy)) then
		p.x=mid(0,newx,127)
		p.y=mid(0,newy,63)
	end
end

function f_interact(x,y)
	if (is_tile(interact,x,y) and mget(x,y)==20 and p.axe==true) then
		get_wood(x,y)
	elseif (is_tile(interact,x,y) and mget(x,y)==68) then
		get_water(x,y)
	elseif (is_tile(interact,x,y) and iswater(x,y) and p.wood>0) then 
		build_bridge(x,y)
	elseif (is_tile(interact,x,y) and iscoin(x,y)) then
		get_coin(x,y)
	elseif (is_tile(interact,x,y) and mget(x,y)==51) then
		talking_fox(x,y)
	elseif (is_tile(interact,x,y) and mget(x,y)==72) then
		talking_cactus(x,y)
	elseif (is_tile(interact,x,y) and mget(x,y)==48) then
		chest(x,y)
	elseif (is_tile(lives,x,y) and (mget(x,y)==160 or mget(x,y)==161)) then
		loose_life(x,y)
	elseif (is_tile(lives,x,y) and (mget(x,y)==80 or mget(x,y)==81)) then
		loose_life(x,y)
	elseif (is_tile(lives,x,y) and (p.life<3) and (mget(x,y)==148 or mget(x,y)==149))  then
		get_life(x,y)
	elseif (is_tile(interact,x,y) and mget(x,y)==130 and not visited_volcano) then
		enter_volcano(x,y)
	end
end


function loose_life(x,y)
	p.life-=1
end

function get_life(x,y)
p.life+=1
next_tile_f(x,y)
end

function next_tile_f(x,y)
	sprite=mget(x,y)
	mset(x,y,146)
end

-->8
--ui

function draw_ui()
	camera()
	palt(0,false)
	palt(14,true)
	
	-- level
	rectfill(1,1,25,7,0)
	print("level"..level(),2,2,7)
	
	-- items
	rectfill(18,15,1,9,0)
	if level()==1 then
		spr(9,1,9)
		palt()
		print("X"..p.wood,10,10,7)
	elseif level()==2 then
		spr(10,1,9)
		palt()
		print("X"..p.water,10,10,7)
	elseif level()==3 then
		spr(11,1,9)
		palt()
		print("X"..p.coin,10,10,7)
	end
	
	-- lives
	palt(0,false)
	palt(11,true)
	if p.life==3 then
		spr(25,119,1)
		spr(25,111,1)
		spr(25,103,1)
		palt()
	elseif p.life==2 then
		spr(25,119,1)
		spr(25,111,1)
		spr(26,103,1)
		palt()
	elseif p.life==1 then
		spr(25,119,1)
		spr(26,111,1)
		spr(26,103,1)
	end
end

function print_outline(text,x,y,color)
	print(text,x-1,y,0)
	print(text,x+1,y,0)
	print(text,x,y+1,0)
	print(text,x,y-1,0)

	print(text,x,y,color)
end
-->8
--animations

function swap_tile(x,y)
 tile=mget(x,y)
 mset(x,y,tile+1)
end
   
function unswap_tile(x,y)
 tile=mget(x,y)
 mset(x,y,tile-1)
end

function toggle_tiles()
    for x=camx,camx+15 do
     for y=camy,camy+15 do
      if (is_tile(anim1,x,y)) then
       swap_tile(x,y)
      elseif (is_tile(anim2,x,y)) then
       unswap_tile(x,y)
      end
     end
    end
end


function swap_coin(x,y)
 tile=mget(x,y)
 mset(x,y,144)
end

function unswap_coin(x,y)
 tile=mget(x,y)
 mset(x,y,145)
end

function flip_coins()
    for x=camx,camx+15 do
     for y=camy,camy+15 do
      if (is_tile(anim1,x,y) and mget(x,y)==145) then
       swap_coin(x,y)
      elseif (is_tile(anim2,x,y) and mget(x,y)==145) then
       unswap_coin(x,y)
      end
     end
    end
end

function flip_ananas()
    for x=camx,camx+15 do
     for y=camy,camy+15 do
      if (is_tile(anim1,x,y) and mget(x,y)==148) then
       swap_tile(x,y)
      elseif (is_tile(anim2,x,y) and mget(x,y)==149) then
       unswap_coin(x,y)
      end
     end
    end
end


-- enemies


function make_enemy()
e={
	x=70,y=30,
	sprite=160
	}
	
b={}

end

function draw_enemy()
	spr(e.sprite,e.x*8,e.y*8,1,1,e.flip)
end

function move_enemy()
	new_ex=e.x
	new_ey=e.y
	if p.x > e.x then
		new_ex+=1/16
		e.flip=false
	elseif p.x < e.x then
		new_ex-=1/16
		e.flip=true
	elseif p.y < e.y then
		new_ey-=1/16
	elseif p.y > e.y then
		new_ey+=1/16
	elseif p.y==e.y and p.x==e.x and p.life>1 and p.coin!=5 then
		new_ey = 30
		new_ex = 70
		p.x = 64
		p.y = 10
		loose_life()
	elseif p.y==e.y and p.x==e.x and p.life==1 and p.coin!=5 then
		new_ey = 30
		new_ex = 70
		state="loosegame"
		sfx(1)
	elseif p.y==e.y and p.x==e.x and p.life>1 and p.coin<5 then
		new_ey = 30
		new_ex = 70
		state="wingame"
	end
	
	if (timer<0) then 
	e.srpite = 161
	else
	e.sprite = 160
	end
	
	if (can_move(new_ex,new_ey)) then
		e.x=mid(0,new_ex,127)
		e.y=mid(0,new_ey,63)
	end
end


-- Boules de feu 

function add_balls()
ball={
x=flr(32+rnd(27)),
y=flr(11+rnd(15)),
sprite=80,
}
add(b,ball)
end

function spawn_balls()
for i=1,5 do
add_balls()
end
end

function draw_balls()
for ball in all(b) do
spr(ball.sprite,ball.x*8,ball.y*8,1,1,ball.flip)
end
end

-- limite x 33 - 62
function move_balls()
for ball in all(b) do
		
		new_bx=ball.x
		new_by=ball.y

		if new_bx==p.x and new_by==p.y and p.life>1 and p.water==0 then
			p.x = 33
			p.y = 07
			loose_life()
		elseif new_bx==p.x and new_by==p.y and p.life>1 and p.water>0 then
			p.x = 33
			p.y = 07
			p.water-=1
			del(ball)
		elseif new_bx==p.x and new_by==p.y and p.life==1 then
			sfx(1)
				state="loosegame"
		elseif p.y==e.y and p.x==e.x and p.life>1 and p.coin<5 then
				state="wingame"		
			else if new_bx < 60 then
			new_bx+=1
			ball.flip=false
		else
			new_bx-=28
		end
	
end
	
	if (timer<0) then 
	ball.srpite = 80
	else
	ball.sprite = 81
	end
	
	ball.x=new_bx

end
end



-->8
--messages

function init_msg()
	messages={}
end

function create_msg(name,...)
	msg_title=name
	messages={...}
end

function clear_msg()
	if (btnp(❎)) then
		deli(messages,1)
	end
end

function draw_popup()
	if msg=="popup" then
		if messages[1] then
			invx=camx*8+25
			invy=camx*8+50
			
			rectfill(invx-1,invy-1,invx+83,invy+25,10)
			rectfill(invx,invy,invx+82,invy+24,0)
			print(msg_title,invx+2,invy+4,7)
			spr(56,invx+72,invy+2)
			print(messages[1],invx+8,invy+15,1)
		end
	elseif msg=="pnj" then
		if messages[1] then
			invx=camx*8+25
			invy=100
			
			--rectfill(invx-1,invy-1,invx+83,invy+25,10)
			rectfill(1,invy+9,126,invy+23,0)
			print_outline(msg_title,4,invy+4,color)
			print(messages[1],3,invy+11,7)
		end
	end
end

__gfx__
000000000000000000000000000000000000000000000000000000000000000000000000ee0000eeeee0eeeeeee00eee00000000000000000000000000000000
000000000f000f0000000000000000000000000000000000000000000000000000000000e0bbbb0eee0c0eeeee0aa0ee00000000000000000000000000000000
007007000ffffff000000000000000000000000000000000000000000000000000000000e0bbbb0ee0ccc0eee0aaaa0e00000000000000000000000000000000
000770000f1fff1000000000000000000000000000000000000000000000000000000000e0b44b0e0ccccc0e0aaaa9a000000000000000000000000000000000
000770000effffe000000000000000000000000000000000000000000000000000000000ee0440ee0c7ccc0e0aaa9aa000000000000000000000000000000000
007007000022200000000000000000000000000000000000000000000000000000000000ee0440eee0ccc0eee0aa9a0e00000000000000000000000000000000
000000000088800000000000000000000000000000000000000000000000000000000000eee00eeeee000eeeee0aa0ee00000000000000000000000000000000
0000000000f0f00000000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeee00eee00000000000000000000000000000000
33333333333333333333333333bbbbb333aaaa33333333333333336d0000000000000000bbbbbbbbbbbbbbbb0000000000000000000000000000000000000000
333333333b33333333a3333333bbbbb33abbbba333333333333336d30000000000000000bb00b00bbb00b00b0000000000000000000000000000000000000000
333333333bb333333a9a33333b33bbb33abbbba333333333333336d30000000000000000b0880880b06606600000000000000000000000000000000000000000
3333333333b33b3333a3333333bb3bb3abbbbbba33333333773336630000000000000000b0888e80b06667600000000000000000000000000000000000000000
3333333333b33bb333333a333bbbbb33abb44bba33333333755656160000000000000000b0888880b06666600000000000000000000000000000000000000000
33333333333333b33333a9a333474433abb44bba3333333335565d6e0000000000000000bb08880bbb06660b0000000000000000000000000000000000000000
33333333333333b333333a33333444333aa44aa3333ff333556665b70000000000000000bbb080bbbbb060bb0000000000000000000000000000000000000000
3333333333333333333333333333443333a44a3333444433355333590000000000000000bbbb0bbbbbbb0bbb0000000000000000000000000000000000000000
cccccccc44444444cccccccc44444444222222224444444400000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccc40004444cccccccc40004444222222224000444400000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccc44400044cc7777cc44400044111111114440004400000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccc44444004cccccccc44444004111111114444400400000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccc44444444cccccccc44444444cccccccc4444444400000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccc40004444cccc777740004444cccccccc4000444400000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccc44400044cccccccc44400044cccccccc4440004400000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccc44444004cccccccc44444004cccccccc4444400400000000000000000000000000000000000000000000000000000000000000000000000000000000
4a4444a44a4aa4a4000000003333333333333333333333333333333300000000600d600038e8e833000000000000000000000000000000000000000000000000
4a4444a4151991510000000033633633336336333333333333333333000000006d666000388e8833000000000000000000000000000000000000000000000000
4a4444a411111111000000003369963333699633333a333333333333000000006666550033888333000000000000000000000000000000000000000000000000
4a4444a41111111100000000339999333399993333a8a3333333333300000000d6600400333b3333000000000000000000000000000000000000000000000000
aaa99aaa1511115100000000330990333309903333a8a333333333330000000006600040333b3333000000000000000000000000000000000000000000000000
191991914a4444a400000000337777333377773733aaa333333333330000000000d60040333b3333000000000000000000000000000000000000000000000000
4a4444a44a4444a400000000336446993364469933a8a33333333333000000000000000433333333000000000000000000000000000000000000000000000000
4a4444a44a4444a4000000003343343733433433333a333333333333000000000000000533333333000000000000000000000000000000000000000000000000
ffffffffffffffffffffffff00000000ffff1fffffffffffffffffff00000000ffffffffffffffffffffffffffffffff00000000000000000000000000000000
ffffffff999fffffff55555f00000000fff11fffffffffffafffffaf00000000fff33ffffff33fffffffffffffffffff00000000000000000000000000000000
ffffffffff99fffff556655500000000ff11c1ffffffffffffaaafff00000000f3fb3feff3fb3feffffaffffffffffff00000000000000000000000000000000
fffffffffffffffff566666500000000f1cccc1ffffffffff9aaaaff00000000fb333f3ffb333f3fffa8afffffffffff00000000000000000000000000000000
fffffffffffffffff566666500000000f1c7cc1ffffffffff9aaaaff00000000fff3bfbffff3bfbfffa8afffffffffff00000000000000000000000000000000
ffffffffffff99fff566665500000000f1c77c1ffffffffff9aaaaff00000000fff3333ffff3333fffaaafffffffffff00000000000000000000000000000000
fffffffffffff999f556665500000000f11ccc1fffffffffff999fff00000000fffb3ffffffb3fffffa8afffffffffff00000000000000000000000000000000
fffffffffffffffff555555f00000000ff1111ffff1111ffafffffaf00000000fff33ffffff33ffffffaffffffffffff00000000000000000000000000000000
00000000000000000000000000000000ffb0b0bffb0b0bff00000000000000000000000000000000000000000000000000000000000000000000000000000000
00088880000888800000000000000000fffbbbffffbbbfff00000000000000000000000000000000000000000000000000000000000000000000000000000000
00899988008998880000000000000000fff9f9ffff9f9fff00000000000000000000000000000000000000000000000000000000000000000000000000000000
0899a988889aa9880000000000000000ff9f949ff949f9ff00000000000000000000000000000000000000000000000000000000000000000000000000000000
889aa9880899a9880000000000000000f9f9494ff4949f9f00000000000000000000000000000000000000000000000000000000000000000000000000000000
00899888008999880000000000000000ff94949ff94949ff00000000000000000000000000000000000000000000000000000000000000000000000000000000
00088880000888800000000000000000f949492ff294949f00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000ff9492ffff2949ff00000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888000000000000000000000000888888888888888800000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888040440400000000000000000888888888888888800000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888000000000000000000000000888888888888888800000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888040440400000000000000000888888888888888800000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888040440400000000000000000888888888888888800000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888000000000000000000000000888888888888888800000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888040440400000000000000000888888888888888800000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888000000000000000000000000888888888888888800000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000d00000500000000000000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000d0000000000000a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddddddd0000050000a8a00000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00d000000000000000a8a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00d000000000000000aaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00d000000050000000a8a00000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddddddd00000000000a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000b0b0b00b0b0b0000000000000000000000000000000000000000000000000000000000000000000000000000000000
007aaa0000aaa7000005000000000000000bbb0000bbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000
07a99a9009a99a70000000000000000000f9f900009f9f0000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a97a490094a79a000000500000000000f9f94900949f9f000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a9aa490094aa9a0000000000000000009f9494004949f9000000000000000000000000000000000000000000000000000000000000000000000000000000000
0aa44a9009a44aa000000000000000000f949490094949f000000000000000000000000000000000000000000000000000000000000000000000000000000000
00999900009999000050000000000000094949200294949000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000009492000029490000000000000000000000000000000000000000000000000000000000000000000000000000000000
08000002080000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08888882088888820000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00888880008888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
008a88a0008a88a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00888880008888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00222220002222200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00222220002222200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00200050000502000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02000008020000080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02222228022222280000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00222220002222200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00202200002022000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00222220002222200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00888880008888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00888880008888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00800050000508000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000005000000000000000000555555555500000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000500000000000000000005aaaaaa99500000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000005000000000000000005555aaaaaa99555500000000000d77700d77700000000000000000000000000000000000000000000000000000000000
000000000555505000055550000000005005a7aaaa9950050000000000d76667d766670000000000000000000000000000000000000000000000000000000000
000000005666655555566665000000000505a7aaaa995050000000000d7666667666667000000000000000000000000000000000000000000000000000000000
000000005666666666666665000000000055a7aaaa995500000000000d7666706706667000000000000000000000000000000000000000000000000000000000
00000000566066666666c665000000000005a7aaaa995000000000000d7666006006667000000000000000000000000000000000000000000000000000000000
0000000056000660606b6865000000000005aaaaaa995000000000000d7666006006667000000000000000000000000000000000000000000000000000000000
00000000566066060666a6650000000000005aaaa99500000000000050d766666666670500000000000000000000000000000000000000000000000000000000
00000000566666666666666500000000000055aa9955000000000000050d76600066705000000000000000000000000000000000000000000000000000000000
000000005666655555566665000000000000055a95500000000000000050d7066607050000000000000000000000000000000000000000000000000000000000
000000000555500000055550000000000000005a950000000000000000050d766670500000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000005a9500000000000000000050d76705000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000055a95500000000000000000050d7050000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000005aaaa995000000000000000000500500000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000055555555000000000000000000055000000000000000000000000000000000000000000000000000000000000000
__gff__
0004000000000000000000000000000000000001030001000000000000000000030003000300000000000000000000000301000301000000000000000000000000000100030000000303000000000000060600001424000000000000000000000001000000000000000000000000000000000000000000000000000000000000
0100020000000000000000000000000012220000142400000000000000000000454500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1313131313131313131313131313131313131313131313131313131313131313424242424242424242424242424242424242424242424242424242424242424280808080808080808080808080808080808080808080808080808080808080800000000000000000000000000000000000000000000000000000000000000000
1313131313131313131313131313131313131313131313131313131313131313424040404040404040404040404040404040404040404040404140404040404280818081818181808181818081818181818081908081818194808181818181800000000000000000000000000000000000000000000000000000000000000000
1313131310101010101010101010101010101010101012101010101010101013424040404040404040404040404040404040404040404040404040404040404280818181808081808080818081808080818081808080808180808081808080800000000000000000000000000000000000000000000000000000000000000000
1310101010101010121010101010101010121010101010391210103910121013424040404040404040404040404040404042404040404040404040404040404280808080808181818181818081808181818081818181808180818181808181800000000000000000000000000000000000000000000000000000000000000000
1313101010101035111110101039101210101010123636101010101010101013424040404040404040404040404040404040404040404040404040404040404280818181818180818081808081808180808081808180808180808081818081800000000000000000000000000000000000000000000000000000000000000000
13101010101010331010101010101010102424242424242424242424242424244040404a4040404040404140404440404040404040404040404040404046404280818080808080808081818181808181818081808181818180818080808181800000000000000000000000000000000000000000000000000000000000000000
131313101410122424242424242424242420202220202220202020202220202040404b48404b4b4b4b424040404040404040404040404040404040404040404280918180818180818080808080808080818080808080808180818181818180800000000000000000000000000000000000000000000000000000000000000000
13131310202020202020222020202020202020202020202020202220202020204040404b4b4b4b4b4b424040404040404040404040404040404040404040404280808080808180818181808180818181818081818181808180808080808181800000000000000000000000000000000000000000000000000000000000000000
1310101020202220202020202020202220202020222020202220202020202020404040404b4b4b4b4b424040404040404040404040404040404040404040404280818181818180818081808181818080808081808081818180818181818081800000000000000000000000000000000000000000000000000000000000000000
1310101022202020202022202020202020202020202010102020202020201013424040404040404040404040404040404040404041404040424040404242424280808080808180808081808080818180818181808181808081818080818181800000000000000000000000000000000000000000000000000000000000000000
1310101020203636363636363636363636101010101010102020202020201013424040404040404040404040404040404040404040404040404040404240408181818292808181818181818180808181818081808080808181808081818080800000000000000000000000000000000000000000000000000000000000000000
1310391010101010101024242424242424242410101210122022202020201013424040404040404040404040404040404040404040404040404040404240404080808081808080818080808181818180808081818181818180808180818181800000000000000000000000000000000000000000000000000000000000000000
1310101010121010101020222022202020202010101014101020202020201013424040404040404044404040404140404040404040404040404040404240404280918081818181818181808080808080818080808080808080818181808081800000000000000000000000000000000000000000000000000000000000000000
1310101110101012101020202020202022202010101210121020202020201013424040404040404040404040404040404040404040404040404040404240404280818080808080808081808181818180818181818181818180808081818081800000000000000000000000000000000000000000000000000000000000000000
1310101111101010101010101010101010111010242424242420202220222413424040404040404040404040404040404040404040404040404040404240404280818181818181818180818180808180808080808180808180808080818181800000000000000000000000000000000000000000000000000000000000000000
1310101110121010101010101010101010101010202020202020202020202013424041404040404040404040404040404040444040404140404040404240404280818080808080808181818080808181808080808080818181818181808180800000000000000000000000000000000000000000000000000000000000000000
1310101110101010101410101010101010101112202020201010101010101013424040404040424040404040404040404040404040404040404040404240404280818080808080808080808081808081818181818181818081808080808180800000000000000000000000000000000000000000000000000000000000000000
1310101010101010101010101010101014101110202020101010101210101013424040404040404040404040404040404040404040404040404040404240404280818181818181808181818181808080808080808080808081818181818181800000000000000000000000000000000000000000000000000000000000000000
1310101010391010101010121030101010121010101010391210101010101213424040404040404040404040404040404040404040404040404040404240404280808080808081808081808081808181808080808081808080808080808081800000000000000000000000000000000000000000000000000000000000000000
1310101014101012103910101010101024241010101010121010121010391013424040404040404040404040404040544040444040404040404040404240404280818181818181808181808081818180808181818081818181818181808181800000000000000000000000000000000000000000000000000000000000000000
1310101010101010101010102424242424201010101010101010101210101013424040404040404040404040404040404040404040404040404040404240404280818080808080808181808181808181818180808081808080808180808180800000000000000000000000000000000000000000000000000000000000000000
1310102424242424242424242020222010101010101010101010101014101013424040404040404040404040404040404040404040404040404040404240404280818181818181808080818180808080818081818081818181808181818180800000000000000000000000000000000000000000000000000000000000000000
1310102020202220202022201010101010101010141039101010101010101013424040404040404040404040404040404040404040404040404040404240404280808080808081808080808080818181818080818080808081808080808180800000000000000000000000000000000000000000000000000000000000000000
1310101010101010101010101010101010101110101010101110101010101013424040404040444040404040404040404040404040404040404040404240404280818181818181818181818180818080808080818181818081809081808181800000000000000000000000000000000000000000000000000000000000000000
1310101210121010101010101010101010101010101010111010101010101013424040404040404040404040404140404040424040404040404040404240544280818181818181818181818180818181818180808180818181808181818081800000000000000000000000000000000000000000000000000000000000000000
1310101014101010101010101010101010101010111010101010391010111013424040404040414040404040404040404040404040414040404140404240404280818181818181818181818180808080808181818180808080808080818081800000000000000000000000000000000000000000000000000000000000000000
1310101210121010101313131010101010101010101010101010111010101013424040404040404040404040404040404040404040404040404040404240404280818181818181818181818180908181818080808180818181818181818081800000000000000000000000000000000000000000000000000000000000000000
1310101010101010131310101010101010131010101010101010101010101013424040424040404040404040404040404040404040404040404040404240404280818181818181818181818180808080818180808180818080808080808081800000000000000000000000000000000000000000000000000000000000000000
1310101010101010101010101010101010101313101013131010101010101013424040424040404040404040404040404040404040404040404040404240404280818181818181818181818180818181808181818180818081948081948081800000000000000000000000000000000000000000000000000000000000000000
1310101010101010101010101010101010101010101010101010101010101013424040424242424242424242424242424242424242424242424242424240404280818181818181818181818180818080808080808180818081808081808081800000000000000000000000000000000000000000000000000000000000000000
1313131339131313131313131313391313133913131313131313131339131313424040404040404040404040404040404040404040404040404040404040404280818181818181818181818180818181818181818180818181818181818181800000000000000000000000000000000000000000000000000000000000000000
1313131313131313131313131313131313131313131313131313131313131313424242424242424242424242424242424242424242424242424242424242424280808080808080808080808080808080808080808080808080808080808080800000000000000000000000000000000000000000000000000000000000000000
__sfx__
000509000c02015020190201d03023040270502b0402e050330503935020050210502305025050260502705028050290502b050340502e0503005031050310503105032050320500000000000000000000000000
001400000070327353273301f3301f3301e3201b340193501634015340143301333014330193301a3501935016300153001430013300143001930000000000000000000000000000000000000000000000000000
00102106393003830031300313003130028200211001d1001c1001e1001f1002010021100211002410029700297002a7002c3002f300283002830029300293002b3002c3002f3003130034100341003800038000
