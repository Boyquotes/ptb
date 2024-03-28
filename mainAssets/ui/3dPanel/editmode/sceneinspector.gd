extends Control
@onready var tree : Tree = $Tree

@onready var tree_root : TreeItem = tree.create_item()
signal selected(item)

func _ready():
	print('ready')
	tree.item_selected.connect(func():
		await get_tree().process_frame
		selected.emit(tree.get_selected().get_metadata(0).node)
		LocalGlobals.clear_gizmos.emit()
		var giz = load("res://mainSystem/scenes/objects/tools/gizmo/gizmo.tscn").instantiate()
		var node = tree.get_selected().get_metadata(0).node
		if !is_instance_valid(node):
			tree.check_children()
			return
		if node is Node3D:
			get_tree().get_first_node_in_group('localworldroot').add_child(giz)
			giz.global_position = node.global_position
			giz.target = node
		)
	var root = get_tree().get_first_node_in_group('localworldroot')
	tree.add_item(root.name,{
		'node':root
	})
	_check_tree_for_updates()
	get_tree().node_added.connect(func(node:Node):
		await get_tree().process_frame
		if root:
			if is_instance_valid(node) and root.is_ancestor_of(node):
				tree.add_item(node.name, {
					'node':node,
					'parent':node.get_parent()
				})
		)
	get_tree().node_renamed.connect(func(node:Node):
		print('node renamed')
		await get_tree().process_frame
		if root:
			if is_instance_valid(node):
				tree.update_item(node)
		)
	get_tree().node_removed.connect(func(node:Node):
		tree.remove_item(node)
		)

func _check_tree_for_updates():
	var root = get_tree().get_first_node_in_group('localworldroot')
	if is_instance_valid(root):
		setRoot(root)
		tree.check_children()

func init():
#	tree.clear()
	tree_root = tree.create_item()
	tree_root.set_text(0,"")

func setRoot(item:Node):
	addchildren(item)

func addchildren(node:Node, parent:Node=null):
	if parent:
		tree.add_item(node.name, {
			'node':node,
			'parent':parent,
		})
	else:
		tree.add_item(node.name,{
			'node':node
		})
	if node.get_child_count() > 0:
		await get_tree().process_frame
		if is_instance_valid(node):
			for i in node.get_children():
				addchildren(i,node)
