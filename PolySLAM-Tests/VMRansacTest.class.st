Class {
	#name : #VMRansacTest,
	#superclass : #VMTests,
	#category : #'PolySLAM-Tests'
}

{ #category : #'as yet unclassified' }
VMRansacTest >> testCreateVectorChains [
	| points vectors ransac chains |
	
	points := { 0@0.  1@1.  2@ -1.  3@0 }.
	vectors := OrderedCollection new.
	
	1 to: points size - 1 do: [ :index |
		vectors add: (VMLineSegment
			from: (points at: index)
			to: (points at: index+1))
	].
	
	ransac := VMRansac new.
	chains := ransac createVectorChains: vectors.
	
	self assert: chains size equals: 1.
	self assert: chains first equals: vectors

]

{ #category : #'as yet unclassified' }
VMRansacTest >> testCreateVectorChains2 [
	| points vectors ransac chains |
	
	points := {
		{ 0@0.  1@1.  2@ -1.  3@0 }.
		{ 4@1.  5@0.  6@1.  7@0 }.
		{ 9@1.  10@1 }.
	}.
	vectors := OrderedCollection new.
	
	points collect: [ :collection |
		1 to: collection size - 1 do: [ :index |
			vectors add: (VMLineSegment
				from: (collection at: index)	
			to: (collection at: index+1))
		].
	].
	
	ransac := VMRansac new.
	chains := ransac createVectorChains: vectors.
	
	self assert: chains size equals: 3.
	self assert: chains first size equals: 3.
	self assert: chains second size equals: 3.
	self assert: chains third size equals: 1.

]

{ #category : #'as yet unclassified' }
VMRansacTest >> testTruncateChainModel [
	| points line vectors ransac result |
	
	points := {
		0@8.  1@0.5.  2@ -1.  3@0.
		4@1.  5@0.    6@1.    7@0.
		9@1.  10@0.5.   11@ -9.
	}.
	line := VMLine pointA: 0@0.5 pointB: 10@0.5.
	
	vectors := OrderedCollection new.
	
	1 to: points size - 1 do: [ :index |
		vectors add: (VMLineSegment
			from: (points at: index)	
		to: (points at: index+1))
	].
	
	ransac := VMRansac new.
	result := ransac truncateChain: vectors model: line.
	
	self assert: result size equals: vectors size - 2.

]
