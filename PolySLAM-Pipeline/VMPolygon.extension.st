Extension { #name : #VMPolygon }

{ #category : #'*PolySLAM-Pipeline-Algo' }
VMPolygon >> asDoublyConnectedEdgeList [
	^ self asDoublyConnectedEdgeListDo: nil
]

{ #category : #'*PolySLAM-Pipeline-Algo' }
VMPolygon >> asDoublyConnectedEdgeListDo: ablock [
	|list link|
	list := DoublyConnectedEdgeList new.
	self do:[: line|
		link := line asPSLinkedEdge.
		list add: link.
		ablock ifNotNil: [ ablock value: link]	
	].
	^ list
	
]

{ #category : #'*PolySLAM-Pipeline-Algo' }
VMPolygon >> calculateIntersectionOn: L 	except: blackList do: aBlock [
	|lastline vertex|
	L isEmpty ifTrue: [ ^self ].
	lastline := nil.
	L do: [ :e|
		lastline
			ifNotNil: [
				(blackList includes:{lastline. e}) ifFalse:[
					"Transcript show: 'Intersection of ', lastline asString, ' and ', e asString; cr."
					vertex := PSVertex intersectionOf: lastline  and: e.
					blackList add: {lastline.e}.
					blackList add: {e. lastline}.
					vertex ifNotNil: [ aBlock value: vertex].
				]
			].
		lastline := e
	]
	
]

{ #category : #'*PolySLAM-Pipeline-Algo' }
VMPolygon >> intersectWith: anotherPolygon [
	^ self intersectWith: anotherPolygon thenDo: nil
]

{ #category : #'*PolySLAM-Pipeline-Algo' }
VMPolygon >> intersectWith: anotherPolygon thenDo: aBlock [
|Q L intersections vertex lut blackList  key D1 D2|

Q := BTree order: 4.
L := BTree order: 4.
lut := Dictionary new.
intersections := OrderedCollection new.
blackList := Set new.
"push all events to Q, a B-Tree, each event coresponding to a vertex of the two polygon"
D1 := self asDoublyConnectedEdgeListDo:[:line| line asPSVertices do:[:v| Q at: (PSVertexKeyY from:v) put: v ]].
D2 := anotherPolygon asDoublyConnectedEdgeListDo:[:line| line asPSVertices do:[:v| Q at: (PSVertexKeyY from:v) put: v ]].
"D2 close.
D1 close."
"get first, calculate intersection"
[ Q isEmpty ] whileFalse: [ 
	vertex := Q root first.
	key := Q root firstKey.
	Q removeKey: key.
	"Transcript show: 'Remove ', key point asString; cr."
	"sweep line event at vertex"
	self sweepEventAt: vertex on:L lut: lut.
	"find intersection points"
	self calculateIntersectionOn: L except: blackList do: [:e|
				Q at:(PSVertexKeyY from:e) put: e.
				intersections add: e	
	].
	"{Q. L} inspect.
	self halt."
].
"visualize two polygon and intersections point"
aBlock ifNotNil: [ ^ aBlock value: intersections value: D1 value: D2 ].
^intersections
]

{ #category : #'*PolySLAM-Pipeline-Algo' }
VMPolygon >> mergeWith: anotherPolygon [
	| line pivot link link1 c|
	self intersectWith: anotherPolygon thenDo:[:intersections :D1 :D2|
		"walkthrough intersection points"
		intersections do:[:point|
			pivot := point segments first.
			line := point segments second.
			(pivot value isPointOnRightSide: line value pointA)
				ifFalse:[
					pivot := point segments second.
					line := point segments first 
			].
			"the head of the list"
			line previousLink
				ifNil:[ 
					line value:(VMLineSegment from: line value pointA to: point ). link := line]
				ifNotNil: [ 
					link := (PSLinkedEdge value:(VMLineSegment from: line value pointA to: point )).
					link previousLink: line previousLink.
					line previousLink nextLink: link].
			"second half segment"
			link1 := (PSLinkedEdge value:(VMLineSegment from: point to: pivot value pointB)).
			link nextLink: link1.
			link1 previousLink: link.
			link1 nextLink: pivot nextLink.
			Transcript show: (VMLineSegment from: line value pointA to: point ) asString, '----->>>>', (VMLineSegment from: point to: pivot value pointB) asString; cr.
	].
	intersections inspect.
	"c := OrderedCollection new.
	c asRenderableElement inspect.
	^ D1 do:[:e|
		c add:e.
		self halt.
	]"
	].
]

{ #category : #'*PolySLAM-Pipeline-Algo' }
VMPolygon >> sweepEventAt: vertex on:L lut: lut [
	|line line1 key key1|
	line := vertex segments at: 1.
	vertex type >= 0 
		ifTrue:[
			key := lut at: line ifAbsent:[nil].
			key 	ifNil: [ 
						"Transcript show: 'start at', vertex asString; cr."
						key:= (PSVertexKeyX from:vertex). L at: key put: line. lut at: line put: key]
					ifNotNil: [ 
						"Transcript show: 'end at', vertex asString; cr."
						L removeKey: key ]
		]
		ifFalse:[
			line1 := vertex segments at: 2.
			key := lut at: line.
			key1 := lut at: line1.
			L removeKey: key.
			L removeKey: key1.
			L at: key put: line1.
			L at: key1 put: line.
			lut at:line1 put: key.
			lut at: line put: key1.
		].
]
