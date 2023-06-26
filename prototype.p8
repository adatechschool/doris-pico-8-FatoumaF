pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
-- aventure
-- fatouma, jeremie, claire

first=true

function _init()	
	map_setup()
	make_player()
	make_enemy()
end

function _update()
	update_map()
	update_camera()	
	move_player()
	move_enemy()
end

function _draw()
	cls()
	draw_map()
	draw_enemy()
	--overlay(first)

	draw_player()
	draw_ui()
end
-->8
-- map

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
	next_tile(x,y)
end

function talking_fox(x,y)
	print("hello")
	next_tile(x,y)
	next_tile(x,y-1)
end

function found_ax(x,y)
	next_tile(x,y)

	invx=40
	invy=8
	
	rectfill(invx,invy,invx+48,invy+30,0)
	print("you found\nan axe !",invx+7,invy+4,7)
	spr(56,invx+20,invy+18)
	
end

function iswater(x,y)
if mget(x,y)==32 or mget(x,y)==34 or mget(x,y)==36
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
-->8
-- player

function make_player()
	p={
		x=2,
		y=2,
		sprite=1,
		wood=0,
		water=0,
		coin=0
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
	if (is_tile(interact,x,y) and mget(x,y)==20) then
	get_wood(x,y)
	elseif (is_tile(interact,x,y) and mget(x,y)==68) then
	get_water(x,y)
	elseif (is_tile(interact,x,y) and iswater(x,y) and p.wood>0) then 
	build_bridge(x,y)
	elseif (is_tile(interact,x,y) and mget(x,y)==145) then
	get_coin(x,y)
	elseif (is_tile(interact,x,y) and mget(x,y)==51) then
	talking_fox(x,y)
	elseif (is_tile(interact,x,y) and mget(x,y)==48) then
	found_ax(x,y)
	end
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
end

function print_outline(text,x,y)
	print(text,x-1,y,0)
	print(text,x+1,y,0)
	print(text,x,y+1,0)
	print(text,x,y-1,0)

	print(text,x,y,7)
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


-- enemies


function make_enemy()
	e={
		x=75,y=23,
		sprite=160
		}
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


 
__gfx__
000000000000000000000000000000000000000000000000000000000000000000000000ee0000eeeee0eeeeeee00eee00000000000000000000000000000000
000000000888888000000000000000000000000000000000000000000000000000000000e0bbbb0eee0c0eeeee0aa0ee00000000000000000000000000000000
00700700088ffff000000000000000000000000000000000000000000000000000000000e0bbbb0ee0ccc0eee0aaaa0e00000000000000000000000000000000
0007700008ff1f1000000000000000000000000000000000000000000000000000000000e0b44b0e0ccccc0e0aaaa9a000000000000000000000000000000000
0007700008fffff000000000000000000000000000000000000000000000000000000000ee0440ee0c7ccc0e0aaa9aa000000000000000000000000000000000
0070070008cccc0000000000000000000000000000000000000000000000000000000000ee0440eee0ccc0eee0aa9a0e00000000000000000000000000000000
0000000008fccc0000000000000000000000000000000000000000000000000000000000eee00eeeee000eeeee0aa0ee00000000000000000000000000000000
000000000001100000000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeee00eee00000000000000000000000000000000
3333333333333333333333333333333333aaaa33333333333333336d000000000000000000000000000000000000000000000000000000000000000000000000
333333333b33333333a3333333bbbb333abbbba333333333333336d3000000000000000000000000000000000000000000000000000000000000000000000000
333333333bb333333a9a333333bbbb333abbbba333333333333336d3000000000000000000000000000000000000000000000000000000000000000000000000
3333333333b33b3333a333333bbbbbb3abbbbbba3333333377333663000000000000000000000000000000000000000000000000000000000000000000000000
3333333333b33bb333333a333bb44bb3abb44bba3333333375565616000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333b33333a9a33bb44bb3abb44bba3333333335565d6e000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333b333333a33333443333aa44aa3333ff333556665b7000000000000000000000000000000000000000000000000000000000000000000000000
3333333333333333333333333334433333a44a333344443335533359000000000000000000000000000000000000000000000000000000000000000000000000
cccccccc44444444cccccccc44444444222222224444444400000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccc40004444cccccccc40004444222222224000444400000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccc44400044cc7777cc44400044111111114440004400000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccc44444004cccccccc44444004111111114444400400000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccc44444444cccccccc44444444cccccccc4444444400000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccc40004444cccc777740004444cccccccc4000444400000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccc44400044cccccccc44400044cccccccc4440004400000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccc44444004cccccccc44444004cccccccc4444400400000000000000000000000000000000000000000000000000000000000000000000000000000000
4a4444a44a4aa4a40000000033333333333333333333333333333333000000000000000000000000000000000000000000000000000000000000000000000000
4a4444a4151991510000000033633633336336333333333333333333000000000000000000000000000000000000000000000000000000000000000000000000
4a4444a411111111000000003369963333699633333a333333333333000000000000000000000000000000000000000000000000000000000000000000000000
4a4444a41111111100000000339999333399993333a8a33333333333000000000000000000000000000000000000000000000000000000000000000000000000
aaa99aaa1511115100000000330990333309903333a8a33333333333000000000000000000000000000000000000000000000000000000000000000000000000
191991914a4444a400000000337777333377773733aaa33333333333000000000000000000000000000000000000000000000000000000000000000000000000
4a4444a44a4444a400000000336446993364469933a8a33333333333000000000000000000000000000000000000000000000000000000000000000000000000
4a4444a44a4444a4000000003343343733433433333a333333333333000000000000000000000000000000000000000000000000000000000000000000000000
ffffffffffffffffffffffff00000000ffff1fffffffffff00000000000000000000000000000000ffffffff4444444400000000000000000000000000000000
ffffffff999fffffff55555f00000000fff11fffffffffff00000000000000000000000000000000ffffffff4444444400000000000000000000000000000000
ffffffffff99fffff556655500000000ff11c1ffffffffff00000000000000000000000000000000ffffffff4444444400000000000000000000000000000000
fffffffffffffffff566666500000000f1cccc1fffffffff00000000000000000000000000000000ffffffff4444444400000000000000000000000000000000
fffffffffffffffff566666500000000f1c7cc1fffffffff00000000000000000000000000000000ffffffff4444444400000000000000000000000000000000
ffffffffffff99fff566665500000000f1c77c1fffffffff00000000000000000000000000000000ffffffff4444444400000000000000000000000000000000
fffffffffffff999f556665500000000f11ccc1fffffffff00000000000000000000000000000000ffffffff4444444400000000000000000000000000000000
fffffffffffffffff555555f00000000ff1111ffff1111ff00000000000000000000000000000000ffffffff4444444400000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00000d00000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddddddd000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00d00000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddddddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007aaa0000aaa7000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07a99a9009a99a700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a97a490094a79a00000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a9aa490094aa9a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0aa44a9009a44aa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00999900009999000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
__gff__
0000000000000000000000000000000000000001030000000000000000000000030003000300000000000000000000000301000301000000000000000000000000000100030000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000
0100000000000000000000000000000010220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1313131313131313131313131313131313131313131313131313131313131313424242424242424242424242424242424242424242424242424242424242424280808080808080808080808080808080808080808080808080808080808080800000000000000000000000000000000000000000000000000000000000000000
1310101010101010101010101010101010101010101010101010101010101013424040404040404040404040404040404040404040404040404140404040404280818081818181808181818081818181818081908081818181808181818181800000000000000000000000000000000000000000000000000000000000000000
131010101010101010101016101010101010101010101010101010101010101342404040404a4a4040404040404040404040404040404040404040404040404280818181808091808080818081808080818081808080808180808081808080800000000000000000000000000000000000000000000000000000000000000000
13101010101010103010101010101010101010101010101010101010101010134240404a4a4a4a4a4a404040404040404042404040404040404040404040404280808080808181818181818081808181818081818181808180818181808181800000000000000000000000000000000000000000000000000000000000000000
131010101010101010101035101010121010101010101010101010101010101342404a4a4a4a4a4a4a4a4040404040404040404040404040404040404040404280818181818180818081808081808180808081808180808180808081818081800000000000000000000000000000000000000000000000000000000000000000
1310101010101010101010331010101010101010101010101010101010101010404a4a4a4a4a4a4a4a4a4140404040404040404040404040404040404040404280818080808080808081818181808181818081808181818180818080808181800000000000000000000000000000000000000000000000000000000000000000
1313131314131313131010101010101010101010101010101010101010101010404a4a4a4a4a4a4a4a424040404040404040404040404044404040404040404280918180818180818080808080808080818080808080808180818181818180800000000000000000000000000000000000000000000000000000000000000000
13101010101010101010101010101010101010101010101010101010101010104040404a4a4a4a4a4a424040404040404040404040404040404040404040404280808080808180818181808180818181818081818181808180808080808181800000000000000000000000000000000000000000000000000000000000000000
1310101010101010101010101010101010101010101010101010101010101010404040404a4a4a4a4a424040404040404040404040404040404040404040404080818181818180818081808181818080808081808081818180818181818081800000000000000000000000000000000000000000000000000000000000000000
1310101010222410101410101010101010101010101010101010101010101013424040404040404040404040404040404040404041404040424040404040404080808080808180808081808080818180818181808181808081818080818181800000000000000000000000000000000000000000000000000000000000000000
1310101020202020201010101010102020202020201010101010101010101013424040404040404040404040404040404040404040404040404040404040408181818192808181818181818180808181818081808080808181808081818080800000000000000000000000000000000000000000000000000000000000000000
1310101020101010102020202020202010101010101010101010101010101013424040404040404040404040404040404040404040404040404040404040404080808081808080818080808181818180808081818181818180808180818181800000000000000000000000000000000000000000000000000000000000000000
1310202020202020202020202020201010101010101010101010101010101013424040404040404044404040404140404040404040404040404040404040404280918081818181818181808080808080818080808080808080818181808081800000000000000000000000000000000000000000000000000000000000000000
1310202010101010101010101010201010101010101010101010101010101013424040404040404040404040404040404040404040404040404040404040404280818080808080808081808181818180818181818181818180808081818081800000000000000000000000000000000000000000000000000000000000000000
1310101010101010101010101010202010101010101010101010101010101013424040404040404040404040404040404040404040404040404040404040404280818181818181818180818180808180808080808180808180808080818181800000000000000000000000000000000000000000000000000000000000000000
1310101010121010101010101010102020202020202020202020202010101013424041404040404040404040404040404040404040404140404040404040404280818080808080808181818080808181808080808080818181818181808180800000000000000000000000000000000000000000000000000000000000000000
1310101010101010101010101010101010101010101020201010101010101013424040404040424040404040404040404040404040404040404040404040404280818080808080808080808081808081818181818181818081808080808180800000000000000000000000000000000000000000000000000000000000000000
1310101010101010101010101010101010101010102020101010101010101013424040404040404040404040404040404040404040404040404040404040404280818181818181808181818181808080808080808080808081818181818181800000000000000000000000000000000000000000000000000000000000000000
1310101010101010101010101010101010101010202010101010101010101013424040404040404040404040404040404040404040404040404040404040404280808080808081808081808081808181808080808081808080808080808081800000000000000000000000000000000000000000000000000000000000000000
1310101010101010101010101010101010102020101010101010101010101013424040404040404040404040404040404040404040404040404040404040404280818181818181808181808081818180808181818081818181818181808181800000000000000000000000000000000000000000000000000000000000000000
1310101010101010101010101010101020201010101010101010101010101013424040404040404040404040404040404040404040404040404040404040404280818080808080808181808181808181818180808081808080808180808180800000000000000000000000000000000000000000000000000000000000000000
1310101010101010101010102020202010101010101010101010101010101013424040404040404040404040404040404040404040404040404040404040404280818181818181808080818180808080818081818081818181808181818180800000000000000000000000000000000000000000000000000000000000000000
1310101020201020202020201010101010101010101010101010101010101013424040404040404040404040404040404040404040404040404040404040404280808080808081808080808080818181818080818080808081808080808180800000000000000000000000000000000000000000000000000000000000000000
1310101010101010101010101010101010101010101010101010101010101013424040404040404040404040404040404040404040404040404040404040404280818181818181818181818180818080808080818181818081809081808181800000000000000000000000000000000000000000000000000000000000000000
1310101010101010101010101010101010101010101010101010101010101013424040404040404040404040404140404040424040404040404040404040404280818181818181818181818180818181818180808180818181808181818081800000000000000000000000000000000000000000000000000000000000000000
1310101010101010101010101010101010101010101010101010101010101013424040404040414040404040404040404040404040414040404140404040404280818181818181818181818180808080808181818180808080808080818081800000000000000000000000000000000000000000000000000000000000000000
1310101010101010101010101010101010101010101010101010101010101013424040404040404040404040404040404040404040404040404040404040404280818181818181818181818180908181818080808180818181818181818081800000000000000000000000000000000000000000000000000000000000000000
1310101010101010101010101010101010101010101010101010101010101013424040424040404040404040404040404040404040404040404040404040404280818181818181818181818180808080818180808180818080808080808081800000000000000000000000000000000000000000000000000000000000000000
1310101010101010101010101010101010101010101010101010101010101013424040404040404040404040404040404040404040404040404040404040404280818181818181818181818180818181808181818180818081928081928081800000000000000000000000000000000000000000000000000000000000000000
1310101010101010101010101010101010101010101010101010101010101013424040404040404040404040404040404040404040404040404040404040404280818181818181818181818180818080808080808180818081808081808081800000000000000000000000000000000000000000000000000000000000000000
1310101010101010101010101010101010101010101010101010101010101013424040404040404040404040404040404040404040404040404040404040404280818181818181818181818180818181818181818180818181818181818181800000000000000000000000000000000000000000000000000000000000000000
1313131313131313131313131313131313131313131313131313131313131313424242424242424242424242424242424242424242424242424242424242424280808080808080808080808080808080808080808080808080808080808080800000000000000000000000000000000000000000000000000000000000000000
