Extension { #name : #VMPolygon }

{ #category : #'*PolySLAM-Pipeline-Algo' }
VMPolygon >> calculateIntersectionOn: L 	except: blackList do: aBlock [
	|lastline vertex|
	L isEmpty ifTrue: [ ^self ].
	lastline := nil.
	L do: [ :e|
		lastline
			ifNotNil: [
				(blackList includes:{lastline. e}) ifFalse:[
					Transcript show: 'Intersection of ', lastline asString, ' and ', e asString; cr.
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
|Q L intersections vertex lut blackList  key|

Q := BTree order: 4.
L := BTree order: 4.
lut := Dictionary new.
intersections := OrderedCollection new.
blackList := Set new.
"push all events to Q, a B-Tree, each event coresponding to a vertex of the two polygon"
self do:[:line| line asPSVertices do:[:v| Q at: (PSVertexKeyY from:v) put: v ]].
anotherPolygon do:[:line| line asPSVertices do:[:v| Q at: (PSVertexKeyY from:v) put: v ]].
"get first, calculate intersection"
[ Q isEmpty ] whileFalse: [ 
	vertex := Q root first.
	key := Q root firstKey.
	Q removeKey: key.
	Transcript show: 'Remove ', key point asString; cr.
	"sweep line event at vertex"
	self sweepEventAt: vertex on:L lut: lut.
	"find intersection points"
	self calculateIntersectionOn: L except: blackList  do: [:e|
		Q at:(PSVertexKeyY from:e) put: e.
		intersections add: e	
	].
	"{Q. L} inspect.
	self halt."
].
"visualize two polygon and intersections point"
^intersections 

]

{ #category : #'*PolySLAM-Pipeline-Algo' }
VMPolygon >> sweepEventAt: vertex on:L lut: lut [
	|line line1 key key1|
	line := vertex segments at: 1.
	vertex type >= 0 
		ifTrue:[
			key := lut at: line ifAbsent:[nil].
			key 	ifNil: [ 
						Transcript show: 'start at', vertex asString; cr.
						key:= (PSVertexKeyX from:vertex). L at: key put: line. lut at: line put: key]
					ifNotNil: [ 
						Transcript show: 'end at', vertex asString; cr.
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
