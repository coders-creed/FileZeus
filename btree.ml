type 'a btree = 
	| Leaf 
	| Node of 'a btree * 'a * 'a btree
	;;

let empty_tree = Leaf
	;;

let rec insert x = function
	| Leaf -> Node(Leaf, x, Leaf)
	| Node(left, n, right) -> 
		if x < n then 
			Node(insert x left, n, right)
		else 
			Node(left, n, insert n right)

	;;		

let rec mem x = function
	| Leaf -> false
	| Node (left, n, right) ->
		if x < n then
			mem x left
		else if x = n then
			true
		else
			mem x right
	;;		

let rec height = function
	| Leaf -> 0
	| Node(left, n, right) ->
		1 + max (height left) (height right)
	;;







