extends Node2D

#存储关节
var joints:PackedVector2Array
#两个关节的长度
var link_size:int=10

#存储角度s
var angles:PackedFloat32Array
#存储限制角度
var angle_constraint:float

@onready var screen_size:Vector2=get_tree().root.size/2
func _ready() -> void:
	create_chain(screen_size,48,64)

#创造链条
func create_chain(origin:Vector2,joint_count:int,l_s:int,ang_constraint:float=360):
	#给链条长度赋值
	link_size=l_s
	#给限制角度赋值
	angle_constraint=ang_constraint
	#添加初始关节
	joints.append(origin)
	#添加初始角度
	angles.append(0.0)
	#填充关节和角度的数组
	for i in range(1,joint_count):
		joints.append(joints[i-1]+Vector2(0,l_s))
		angles.append(0.0)
		pass
		
func _physics_process(delta: float) -> void:
	reslove(get_viewport().get_mouse_position())
	queue_redraw()
	pass

func reslove(pos:Vector2):
	#给角度数组的第一个元素赋值
	angles[0]=rad_to_deg((pos-joints[0]).angle())
	#给关节数组第一个元素赋值
	joints[0]=pos
	#遍历关节数组
	for i in range(1,joints.size()):
		#返回当前关节和上一个关节基于x正半轴夹角
		var cur_angle:float=rad_to_deg((joints[i-1]-joints[i]).angle())
		#重新给角度数组赋值
		angles[i]=constrain_angle(cur_angle,angles[i-1],angle_constraint)
		#重新给关节数组赋值，当前关节的位置是上一个关节的位置减去偏移量
		joints[i]=joints[i-1]-(Vector2(1,0).rotated(deg_to_rad(angles[i]))).normalized()*link_size

func fabrik_resolve(pos:Vector2,anchor:Vector2):
	joints[0]=pos
	for i in range(1,joints.size()):
		joints[i]=constrain_distance(joints[i],joints[i-1],link_size)
	joints[joints.size()-1]=anchor
	for i in range(joints.size()-2,0,-1):
		joints[i]=constrain_distance(joints[i],joints[i+1],link_size)

func _draw() -> void:
	for i in range(joints.size()-1):
		var start_joint:Vector2=joints[i]
		var end_joint:Vector2=joints[i+1]
		draw_line(start_joint,end_joint,Color.AQUA,8)
	for i in joints:
		draw_circle(i,100,Color.AQUA,false,3)
	
	
	##限制两点的距离
func constrain_distance(pos:Vector2,anchor:Vector2,constraint:float):
	var dir:Vector2=(pos-anchor).normalized()
	var final_result:Vector2=dir*constraint
	return anchor+final_result
	
	##限制角度
func constrain_angle(angle:float,anchor:float,constraint):
	if abs(relative_angle_dirr(angle,anchor))<=constraint:
		#print("第一个")
		return simplify_angle(angle)
	if relative_angle_dirr(angle,anchor)>constraint:
		#print("第二个")
		return simplify_angle(angle-constraint)  
	#print("最后一个")
	return simplify_angle(angle+constraint)

	##想一想angle需要旋转多少度能到anchor
func relative_angle_dirr(angle:float,anchor:float):
	angle=simplify_angle(angle+180.0-anchor)
	anchor=180.0
	return anchor-angle

	##将角度简化在0到360
func simplify_angle(angle:float):
	while angle >=360.0:
		angle-=360.0
	while angle<0:
		angle+=360.0
	return angle
