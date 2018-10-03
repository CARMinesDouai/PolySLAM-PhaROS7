Class {
	#name : #VMQuadTreeTests,
	#superclass : #VMTests,
	#category : #'PolySLAM-Tests'
}

{ #category : #tests }
VMQuadTreeTests >> testAddingPoints [
	"adding points to a quad tree that already has a fitting width & height"
	| root data |
	
	root := VMQuadTreeNode size: 8@8 center: 0@0.
	
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
	
	data do: [ :point |
		root add: point.
	].

	"with this test we are already happy if it terminates (i.e. is not stuck in an infinite loop) and doesn't throw any exceptions"
	self assert: true.

]

{ #category : #tests }
VMQuadTreeTests >> testAddingPoints2 [
	"adding points to a quad tree that has to grow, creating new parent nodes.
	we check the size of a few selected nodes, including the new true root of the tree."
	| root data expectedSize |
	
	expectedSize := {0. 1. 12. 15. 17}.
	root := VMQuadTreeNode size: 1@1 center: 0@0.
	
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
	
	data do: [ :point |
		root add: point.
	].
	
	expectedSize do: [ :size |
		"Transcript
			show: 'size at old root=', (root size) printString;
			cr.
		"
		self assert: (size = root size).
		root := root parent.
	].
	

]

{ #category : #tests }
VMQuadTreeTests >> testContructFromCollection [
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
	
	root := data asVMQuadTree.
	self assert: (root size = data size).
	
	root := data asOrderedCollection asVMQuadTree.
	self assert: (root size = data size).

]

{ #category : #tests }
VMQuadTreeTests >> testFindNearest [
	"in this test we check the findNearest method. for this we create a data set of points that spiral around a given point. we add point
	after point from the data set, starting with the point furthest away, and call findNearest each time. since the latest added point is by
	construction the closest point, we can easily check the result within an assert call."
	| point root stepSize dataSize data radius |
	
	point := 1.3@0.2.
	root := VMQuadTreeNode size: (10@10) center: (0@0).
	
	stepSize := Float pi * 0.3.
	dataSize := 20.
	data := OrderedCollection new.
	radius := 4.0.
	
	1 to: dataSize do: [ :i |
		data add: ( (stepSize * i sin * radius + point x) @ (stepSize * i cos * radius + point y) ).
		radius := radius * 0.8.
	].
	
	data do: [ :obj |
		| result |
		root add: obj.
		result := root findNearest: point.
		self assert: (result object) = obj.
	].

]

{ #category : #tests }
VMQuadTreeTests >> testSize [
	| root data |
	
	root := VMQuadTreeNode size: 8@8 center: 0@0.
	
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
	
	data do: [ :point |
		root add: point.
	].

	Transcript show: 'child 1 size=', (root children at: 1) size printString; cr.
	self assert: ((root children at: 1) size = 1).
	Transcript show: 'child 2 size=', (root children at: 2) size printString; cr.
	self assert: ((root children at: 2) size = 2).
	Transcript show: 'child 3 size=', (root children at: 3) size printString; cr.
	self assert: ((root children at: 3) size = 5).
	Transcript show: 'child 4 size=', (root children at: 4) size printString; cr.
	self assert: ((root children at: 4) size = 9).

]
