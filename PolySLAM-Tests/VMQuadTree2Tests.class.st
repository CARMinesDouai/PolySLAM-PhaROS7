Class {
	#name : #VMQuadTree2Tests,
	#superclass : #VMTests,
	#category : #'PolySLAM-Tests'
}

{ #category : #tests }
VMQuadTree2Tests >> testAdd [
	"in this test we are adding points that don't require the tree to grow in any way. the test succeeds if we don't rise any signals."
	| root data |
	
	root := VMQuadTreeNode2 rectangle: (Rectangle origin: 0.0@0.0 corner: 1.0@1.0).
	
	data := {
		0.1 @ 0.1.
		0.1 @ 0.9.
		0.9 @ 0.1.
		0.9 @ 0.9.
	}.
	
	data do: [ :aPoint |
		root add: aPoint.
	].
	

]

{ #category : #tests }
VMQuadTree2Tests >> testAdd2 [
	"in this test we add enough point to force the tree to grow (at the leafs). the test succeeds if we don't rise any signals."
	| root data |
	
	root := VMQuadTreeNode2 rectangle: (Rectangle origin: 0@0 corner: 1@1).
	
	data := {
		0.1 @ 0.1.
		0.2 @ 0.1.
		0.3 @ 0.1.
		0.4 @ 0.1.
		0.6 @ 0.1.
		0.7 @ 0.1.
		0.8 @ 0.1.
		0.1 @ 0.2.
		0.2 @ 0.2.
		0.6 @ 0.2.
		0.7 @ 0.2.
		0.1 @ 0.3.
		0.2 @ 0.3.
		0.1 @ 0.9.
		0.9 @ 0.1.
		0.9 @ 0.9.
	}.
	
	data do: [ :aPoint |
		root add: aPoint.
	].

]

{ #category : #tests }
VMQuadTree2Tests >> testContructFromCollection [
	"adding points to a quad tree that has to grow, creating new parent nodes.
	we check the size of a few selected nodes, including the new true root of the tree."
	| root data |
	
	data := {
		1@1.
		0.333@2.
		0.333@2.1.
		0.3@2.2.
		0.3@2.21.
		0.3@2.2.
		0.3@2.22.
		0.3@2.23.
		0.5@2.2.
		1@ -2.
		1@ -1.4.
		-2@ -2.
		-0.5@ 3.
		-0.5@ 3.2.
		-0.5@ 3.4.
		-0.5@ 3.6.
		-0.5@ 3.8.
	}.
	
	root := data asVMQuadTree2.
	self assert: root size equals: data size.

]

{ #category : #tests }
VMQuadTree2Tests >> testContructFromCollection2 [
	"adding points to a quad tree that has to grow, creating new parent nodes.
	we check the size of a few selected nodes, including the new true root of the tree."
	| root data |
	
	data := {  -3 @ -3.  -2 @ -2.  -1 @ -1.  0@0. 1@1.  2@2.  3@3.  }.
	
	root := data asVMQuadTree2.
	self assert: root size equals: data size.

]

{ #category : #tests }
VMQuadTree2Tests >> testEmptyConstruction [
	| root |
	"test succeeds if it does not rise any signals"
	root := VMQuadTreeNode2 rectangle: (Rectangle origin: 0@0 corner: 1@1).

]

{ #category : #tests }
VMQuadTree2Tests >> testFindNearest [
	"in this test we check the findNearest method. for this we create a data set of points that spiral around a given point. we add point
	after point from the data set, starting with the point furthest away, and call findNearest each time. since the latest added point is by
	construction the closest point, we can easily check the result within an assert call."
	| point root stepSize dataSize data radius |
	
	point := 1.3@0.2.
	root := VMQuadTreeNode2 rectangle: (Rectangle origin: -5@ -5 corner: 5@5).
	
	stepSize := Float pi * 0.3.
	dataSize := 20.
	data := OrderedCollection new.
	radius := 4.0.
	
	1 to: dataSize do: [ :i |
		| angle |
		angle := stepSize * i.
		data add: point + ( (angle sin * radius) @ (angle cos * radius) ).
		radius := radius * 0.8.
	].
	
	data do: [ :obj |
		| result |
		root add: obj.
		result := root root findNearest: point.
		self assert: (result object) equals: obj.
	].

]

{ #category : #tests }
VMQuadTree2Tests >> testGetIndex [
	"a quick test if the #getIndex method returns the correct results"
	| node data |
	
	node := VMQuadTreeNode2 rectangle: (Rectangle origin: 0@0 corner: 1@1).
	
	data := {
		{0.1@0.1.  1}.
		{0.9@0.1.  2}.
		{0.1@0.9.  3}.
		{0.9@0.9.  4}.
	}.
	
	data do: [ :obj |
		self assert: (node getIndex: obj first) equals: obj second.
	].
	

]

{ #category : #tests }
VMQuadTree2Tests >> testGrowUpwards [
	| root |
	
	root := VMQuadTreeNode2 rectangle: (Rectangle origin: 0@0 corner: 1@1).
	
	root add: (-0.5 @ -0.5).
	
	"when we grow upwards, the new root must differ from the current node"
	self assert: (root ~= root root).
	"since we had to grow, the new point must not have been added to the current node"
	self assert: (root size = 0).
	"the new point must be found when looking at the new root"
	self assert: (root root size = 1).

]

{ #category : #tests }
VMQuadTree2Tests >> testGrowUpwards2 [
	| root |
	
	root := VMQuadTreeNode2 rectangle: (Rectangle origin: 0@0 corner: 1@1).
	
	root add: (1.5 @ -0.5).
	
	"when we grow upwards, the new root must differ from the current node"
	self assert: (root ~= root root).
	"since we had to grow, the new point must not have been added to the current node"
	self assert: (root size = 0).
	"the new point must be found when looking at the new root"
	self assert: (root root size = 1).

]

{ #category : #tests }
VMQuadTree2Tests >> testGrowUpwards3 [
	| root |
	
	root := VMQuadTreeNode2 rectangle: (Rectangle origin: 0@0 corner: 1@1).
	
	root add: (-0.5 @ 1.5).
	
	"when we grow upwards, the new root must differ from the current node"
	self assert: (root ~= root root).
	"since we had to grow, the new point must not have been added to the current node"
	self assert: (root size = 0).
	"the new point must be found when looking at the new root"
	self assert: (root root size = 1).

]

{ #category : #tests }
VMQuadTree2Tests >> testGrowUpwards4 [
	| root |
	
	root := VMQuadTreeNode2 rectangle: (Rectangle origin: 0@0 corner: 1@1).
	
	root add: (1.5 @ 1.5).
	
	"when we grow upwards, the new root must differ from the current node"
	self assert: (root ~= root root).
	"since we had to grow, the new point must not have been added to the current node"
	self assert: (root size = 0).
	"the new point must be found when looking at the new root"
	self assert: (root root size = 1).

]

{ #category : #tests }
VMQuadTree2Tests >> testRectangle [
	"this test is for the Rectangle class, in particular for the #center method. note, that several other methods in Rectangle also depend on the result of #center."
	| rect data epsilon |
	
	epsilon := 0.000001.
	
	data := {
		{ 0@0.  2@2.  1@1 }. "this is the only one that worked with the original method"
		{ 0@0.  1@1.  0.5@0.5 }.
		{ 0@0.  3@2.  1.5@1 }.
		{ -3@ -3.  0@0.  -1.5@ -1.5 }.
		{ 0@ -2.  3@9.  1.5@3.5 }.
	}.
	
	data do: [ :obj |
		rect := VMRectangle origin: obj first corner: obj second.
		self assert: ((rect center dist: obj third) < epsilon).
	].

]

{ #category : #tests }
VMQuadTree2Tests >> testSize [
	"in this test we add enough point to force the tree to grow (at the leafs), and test if the result of #size matches our expectations"
	| root data |
	
	root := VMQuadTreeNode2 rectangle: (Rectangle origin: 0.0@0.0 corner: 1.0@1.0).
	
	data := {
		0.1 @ 0.1.
		0.2 @ 0.1.
		0.3 @ 0.1.
		0.4 @ 0.1.
		0.6 @ 0.1.
		0.7 @ 0.1.
		0.8 @ 0.1.
		0.1 @ 0.2.
		0.2 @ 0.2.
		0.6 @ 0.2.
		0.7 @ 0.2.
		0.1 @ 0.3.
		0.2 @ 0.3.
		0.1 @ 0.9.
		0.9 @ 0.1.
		0.9 @ 0.9.
	}.
	
	data doWithIndex: [ :aPoint :index |
		root add: aPoint.
		self assert: root size equals: index.
	].

]

{ #category : #tests }
VMQuadTree2Tests >> testSquaredDistanceTo [
	"tests the square distance between a node and a point. points inside the node have a distance of zero"
	| node data epsilon |
	
	epsilon := 0.000001.
	node := VMQuadTreeNode2 rectangle: (Rectangle origin: 4.0@4.0 corner: 8.0@8.0).
	data := {
		{5@5.  0}.
		{1@1.  18}.
		{2@4.  4}.
		{4@2.  4}.
		{10@5.  4}.
		{6@11.  9}.
		{9@12.  17}.
	}.
	
	data do: [ :obj |
		| dist |
		dist := node squaredDistanceTo: obj first.
		self assert: (dist - obj second) abs < epsilon.
	].

]
