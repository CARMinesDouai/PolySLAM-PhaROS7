"
VMClosedPolygon

This class models a simple polygon (see https://en.wikipedia.org/wiki/Simple_polygon). The polygon will have either a clockwise (CW) or counter-clockwise (CCW) winding order, which defines whether the polygon is hollow (CW) or solid (CCW). Note, that hollow polygons are solid on the outside, and therefore used to define the boundaries of the map.

messages:
	intersectsWithLine: <VMLineSegment>
		returns true, if the polygon intersects with the given line segment returns false otherwise.
	isPointInside: <Point or VMGraphVertex>
		returns true if the provided point lies within the polygon. returns false otherwise.
	isSimple
		always returns true, since the polygon must be simple to be valid.
	pointsInward: <Point> index: <Integer>
		returns true, if the provided vector points inside the polygon from the vertex identified via index.
	render: <VMRenderOptions>
		draws the polygon on the surface provided via the render options.
"
Class {
	#name : #VMClosedPolygon,
	#superclass : #VMVerticesPolygon,
	#category : #'PolySLAM-Extra-Deprecated'
}

{ #category : #merging }
VMClosedPolygon >> computeIntersections: lineSeg lineSegs: lineSegCollection [
	"computes the intersections between lineSeg and all line segments in lineSegCollection. we are looking for the intersection closest to the start point of lineSeg.
	we return an OrderedCollection with contains an Array with the vertex of the intersection, the relative distance (as a factor), and the line segment that
	intersected with lineSeg. if multiple intersections are equally closest to lineSeg's starting point, the returned OrderedCollection contains multiple arrays."
	| results factor epsilon |
	
	results := OrderedCollection new.
	factor := 2.0.		"the current distance (as a factor in the range of 0 to 1) of the intersection closest to the starting point of the line segment 'cur'."
	epsilon := 0.000001.
	
	"compute intersections with our current line segment 'cur'."
	lineSegCollection do: [ :ls |
		lineSeg ifIntersectsWith: ls do: [ :p :f |
			f > epsilon ifTrue: [
				Transcript show: 'intersection f=', f printString, ' p=', p printString, '(',ls pointA printPoint, ' / ', ls pointB printPoint,')'; cr.
				
				(f = factor) ifTrue: [ results add: { p. f. ls. }. ].
				(f < factor) ifTrue: [ factor := f. results removeAll. results add: { p. f. ls. }. ].
			].
		].
	].

	^results.
		

]

{ #category : #expand }
VMClosedPolygon >> expand: size [
	| newVertices |
	
	newVertices := OrderedCollection new.
	
	vertices doWithIndex: [ :v :i |
		newVertices addAll: (self expand: size atIndex: i).
	].
	
	
	^( VMClosedPolygon fromOrderedVertices: newVertices ).
	





]

{ #category : #'private: expand helper' }
VMClosedPolygon >> expand: size atIndex: index [
	| newVertices left right vertex expandVector angle |
	
	newVertices := OrderedCollection new.
	
	vertex := vertices at: index.
	left := vertices atWrap: (index-1).
	right := vertices atWrap: (index+1).
	angle := (vertex - left) angleWith: (right - vertex).
	Transcript
		show: 'angle between line segments=', angle printString, ' (', (angle * 360 / (Float twoPi))printString ,')';
		cr.
	
	((angle > (Float pi * 0.5)) and: [angle < (Float pi)]) ifTrue: [
		newVertices addAll: (self expandIntoTwoVertives: size atIndex: index).
		^newVertices.
	].
	
	expandVector := self getExpandVectorPrev: (vertex point - (left point)) next: (right point - (vertex point)) expand: size.
	newVertices add: (VMGraphVertex point: (vertex + expandVector)).
	
	
	^newVertices
	
]

{ #category : #'private: expand helper' }
VMClosedPolygon >> expandIntoTwoVertives: size atIndex: index [
	| newVertices vertex left right leftLine rightLine capLine |
	newVertices := OrderedCollection new.
	
	vertex := vertices at: index.
	left := vertices atWrap: (index-1).
	right := vertices atWrap: (index+1).
	
	leftLine := self getExpandLineSeg: size from: left to: vertex.
	rightLine := self getExpandLineSeg: size from: vertex to: right.
	capLine := self getExpandCapLine: size prev: left current: vertex next: right.
	
	newVertices add:
		(VMGraphVertex point:
			(leftLine intersectionPointOrNilWith: capLine)).	
	
	newVertices add:
		(VMGraphVertex point:
			(rightLine intersectionPointOrNilWith: capLine)).
	
	^newVertices.
]

{ #category : #constructing }
VMClosedPolygon >> fromOrderedVertices: collection [
	"takes an ordered collection of VMGraphVertex objects as parameter and builds the polygon from them"
	
	| prevIndex nextIndex |
	
	vertices := OrderedCollection new.
	
	"returns the previous index"
	prevIndex := [ :i |
		| index |
		(i-1) < 1 ifTrue: [
			index := collection size.
		] ifFalse: [
			index := (i-1).
		].
		index
	].
	
	"returns the next index"
	nextIndex := [ :i |
		| index |
		(i+1) > (collection size) ifTrue: [
			index := 1.
		] ifFalse: [
			index := (i+1).
		].
		index
	].
	
	"error check: collection must not be empty"
	collection ifEmpty: [
		Transcript show: 'empty collection - cannot create polygon'; cr.
		^self.
	].
	
	minX := collection first x.
	maxX := collection first x.
	minY := collection first y.
	maxY := collection first y.
	
	"error checking: we need at least three points ot create a polygon."
	collection size < 3 ifTrue: [
		Transcript show: 'not enough points to create a polygon (size=', (collection size)printString, ')'; cr.
		^self.
	].
	
	"update min/max values and add vertices to the collection"
	collection do: [ :p |
		minX > (p x) ifTrue: [ minX := (p x). ].
		maxX < (p x) ifTrue: [ maxX := (p x). ].
		minY > (p y) ifTrue: [ minY := (p y). ].
		maxY < (p y) ifTrue: [ maxY := (p y). ].
		
		vertices add: p.
	].
	
	"connect vertices, in case that they are used outside of this polygon too."
	vertices doWithIndex: [ :v :i |
		v addNeighbor: (vertices at: (prevIndex value: i)).
		v addNeighbor: (vertices at: (nextIndex value: i)).
	].
	
	"create a reference from each vertex to this polygon"
	self markVertices.
	
	"compute the winding order and save it"
	cw := self testCW.
	
	Transcript show: 'polygon size=',(vertices size)printString,', cw=',(cw printString); cr.
	

]

{ #category : #'private: expand helper' }
VMClosedPolygon >> getExpandCapLine: size prev: vertexA current: vertexB next: vertexC [
	"returns a VMLineSegement object that is perpendicular to the expand-vector."
	| expandVec linePoint |
	expandVec := self getExpandVec: size prev: vertexA current: vertexB next: vertexC.
	
	linePoint := vertexB + expandVec.
	
	^VMLineSegment from: linePoint to: (linePoint + (expandVec normal)).
]

{ #category : #'private: expand helper' }
VMClosedPolygon >> getExpandLineSeg: size from: vertexA to: vertexB [
	"returns a VMLineSegment object that is parallel to the line vertexA->vertexB, but shifted by 'size'."
	| normal |
	normal := ((vertexB - vertexA) normal) * size.
	
	^VMLineSegment from: (vertexA - normal) to: (vertexB - normal).
]

{ #category : #'private: expand helper' }
VMClosedPolygon >> getExpandVec: size prev: vertexA current: vertexB next: vertexC [
	"returns a vector of length 'size' that points in the direction of expansion."
	
	| expandVec prevNormal prev next |
	
	prev := vertexB - vertexA.
	next := vertexC - vertexB.
	
	expandVec := ((prev normalized) - (next normalized)).
	prevNormal := prev normal.
	
	"check if 'prev' and 'next' are parallel. in that case, our vector 'a' has zero length."
	((expandVec x = 0) and: (expandVec y = 0)) ifTrue: [
		expandVec := prevNormal.
	] ifFalse: [
		expandVec := expandVec normalized.
	].
	
	^(expandVec * size).
]

{ #category : #merging }
VMClosedPolygon >> getNextLineSeg: vertex list: lineSegs [
	| intersections |
	
	intersections := OrderedCollection new.
	
	lineSegs do: [ :ls |
		(ls pointA) = vertex ifTrue: [ intersections add: ls ].
	].
	
	(intersections size) ~= 1 ifTrue: [ 1 halt. ].
	
	self assert: ((intersections size) > 0).		"since we have closed polygons, there should always be two line segments that are connected to this vertex - on with it as a start point and one with it as the end point"
	self assert: ((intersections size) < 2).		"for the same reason as above, there should not be more than one result ... unless two polygons are touching at a corner. we will have to deal with this case some time in the future"
	
	^intersections first.
]

{ #category : #merging }
VMClosedPolygon >> getNextLineSeg: vertex list: lineSegs prev: prevLineSeg [
	| intersections prevAngle result greatesDeltaAngle |
	
	intersections := OrderedCollection new.
	
	lineSegs do: [ :ls |
		(ls pointA) = vertex ifTrue: [ intersections add: ls ].
	].
	
	"(intersections size) ~= 1 ifTrue: [ 1 halt. ]."
	
	self assert: ((intersections size) > 0).		"since we have closed polygons, there should always be two line segments that are connected to this vertex - on with it as a start point and one with it as the end point"
	
	"angle in rad"
	prevAngle := prevLineSeg angle.
	
	result := intersections first.
	greatesDeltaAngle := result angle - prevAngle.
	
	2 to: (intersections size) do: [ :i |
		| deltaAngle |
		deltaAngle := (intersections at: i) angle - prevAngle.
		
		deltaAngle > greatesDeltaAngle ifTrue: [
			result := intersections at: i.
			greatesDeltaAngle := deltaAngle.
		].
		
		deltaAngle = greatesDeltaAngle ifTrue: [
			Transcript show: 'warning: more than one possible greatest delta angle while merging'
		].
	].
	
	^result.
]

{ #category : #accessing }
VMClosedPolygon >> indexLeftOf: index [
	"returns the index left of the provided index. warps around when out of bounds"
	
	| newIndex |
	
	newIndex := index - 1.
	newIndex < 1 ifTrue: [
		^vertices size.
	].

	^newIndex.
]

{ #category : #accessing }
VMClosedPolygon >> indexRightOf: index [
	"returns the index left of the provided index. warps around when out of bounds"
	
	| newIndex |
	
	newIndex := index + 1.
	newIndex > (vertices size) ifTrue: [
		^1.
	].

	^newIndex.
]

{ #category : #testing }
VMClosedPolygon >> intersectsWithLine: lineSeg [
	| nextIndex |
	
	nextIndex := [ :i |
		| index |
		index := i + 1.
		index > (vertices size) ifTrue: [ index := 1. ].
		index
	].
	
	vertices doWithIndex: [ :v :i |
		| line |
		line := VMLineSegment from: v to: (vertices at: (nextIndex value: i)).
		
		(lineSeg intersectsWith: line) ifTrue: [ ^true. ].
	].
	
	^false.
]

{ #category : #private }
VMClosedPolygon >> isLeft: p a: a b: b [
	"returns True if the point p is left of the line which is defined by the two points a and b.
	the line must not be parallel to the x axis, i.e. a.y and b.y must not be identical."
	
	| u v w z |
	
	u := (a y) - (p y).
	v := (a y) - (b y).
	w := (b x) - (a x).
	
	z := (a x) + (w * u / v).
	
	(p x) < z ifTrue: [
		^true.
	].

	^false.
]

{ #category : #testing }
VMClosedPolygon >> isPointInside: point [
	"returns True if the point lies inside the polygon and False otherwise"
	
	| wn |
	
	"test against the bounding box first"
	point x < minX ifTrue: [ ^false. ].
	point x > maxX ifTrue: [ ^false. ].
	point y < minY ifTrue: [ ^false. ].
	point y > maxY ifTrue: [ ^false. ].
	
	wn := self windingNumber:point.
	
	self logCr: 'winding number=', (wn printString).
	
	wn ~= 0 ifTrue: [
		^true.
	].
	^false.
]

{ #category : #'as yet unclassified' }
VMClosedPolygon >> lineSegments [
	| collection |
	collection := super lineSegments.
	collection add: (  VMLineSegment from: vertices last to: vertices first  ).
	^collection.
]

{ #category : #logging }
VMClosedPolygon >> logCr: aString [
	"Log the argument. Use self logCr: 'something' instead of Transcript show: 'something'  ; cr "
	
	Transcript show: aString ; cr.
]

{ #category : #'winding order' }
VMClosedPolygon >> makeCCW [
	"ensures that the polygon's winding is counter-clock-wise"
	cw ifTrue: [
		self reverse.
	].
	
	cw := false.

]

{ #category : #'winding order' }
VMClosedPolygon >> makeCW [
	"ensures that the polygon's winding is counter-clock-wise"
	cw ifFalse: [
		self reverse.
	].
	
	cw := true.

]

{ #category : #merging }
VMClosedPolygon >> merge: aCollection [
	|	start				"the vertex at which we start the main algorithm. also used to determine when the algorithm finishes"
		cur				"the current line segment that we are processing"
		lineSegs		"an OrderedCollection instance that stores all line segments from all polygons that we merge"
		allPolygons	"a collection of all polygons that we merge with the current polygon"
		startLineSeg	"the line segment with which we start the algorithm"
		finalVertices		"an OrderedCollection instance that contains all vertices from the merged polygon in order"
		abortCounter	"a counter to break in case we are stuck in an invinit loop"
	|
	
	start := vertices first.
	lineSegs := OrderedCollection new.
	allPolygons := OrderedCollection new.
	startLineSeg := nil.
	finalVertices := OrderedCollection new.
	abortCounter := 1000.		"for debugging, we set the maximum number of loop iterations to break invinite loops"
	
	allPolygons add: self.
	aCollection ifNotNil: [ allPolygons addAll: aCollection. ].
	
	allPolygons do: [ :p |
		p vertices doWithIndex: [ :v :i |
			| line |
			"create a line segment and store it"
			line := VMLineSegment from: v to: (p vertices atWrap: (i+1)).
			lineSegs add: line.
			
			"check if the vertex is further to the right then 'start'. if both have the same x value, we choose the one with the higher y value"
			(start x) < (v x) ifTrue: [ start := v. startLineSeg := line. ].
			(start x) = (v x) ifTrue: [
				(start y) < (v y) ifTrue: [ start := v. startLineSeg := line. ].
			].
		].
	].
	Transcript show: 'start=', start printPoint, ' ', self printString; cr.
	
	"the only possible reason why 'startLineSeg' could be nil is, that our very first vertex already was
	the right-most vertex. in that case, the first element in 'lineSegs' is the correct starting lineSeg."
	startLineSeg ifNil: [ startLineSeg := lineSegs first. ].
	cur := startLineSeg.
	
	finalVertices add: start.
	
	"note: the loop abort condition (aside from the counter) is to reach the start vertex 'start' without any further splitting of the 'cur' line segment."
	[ abortCounter > 0 ] whileTrue: [
		| intersections |
		
		abortCounter := abortCounter - 1.
		intersections := self computeIntersections: cur lineSegs: lineSegs.
		
		"act according to the intersections (or lack of it)"
		intersections ifEmpty: [
			"if there are no intersections, we simply add the line segment (or rather the line segments end point) to our collection"
			Transcript show: 'empty'; cr.
			(cur pointB) = start ifTrue: [ ^VMClosedPolygon fromOrderedVertices: finalVertices. ].
			finalVertices add: (cur pointB).
			cur := self getNextLineSeg: (cur pointB) list: lineSegs prev: cur.
		] ifNotEmpty: [
			"if there is one or more intersections, we add the intersection to the vertexCol collection and create a new line segment to continue"
			| res |
			Transcript show: 'not empty ',(intersections first at: 1)printString, (intersections first at: 2)printString; cr.
			"for testing, we currently just take the first result, even if we have multiple equal results"
			res := intersections first.
			"self assert: (intersections size = 1)."
			
			finalVertices add: (VMGraphVertex point: (res at: 1)).
			cur := VMLineSegment from: (res at: 1) to: ((res at: 3) pointB).
		].
	].
	
	self assert: (finalVertices size > 2).
	
	Transcript show: 'counter=', abortCounter printString; cr.
	^VMClosedPolygon fromOrderedVertices: finalVertices.























]

{ #category : #testing }
VMClosedPolygon >> pointsInward: vec index: index [
	"returns true if the vector 'vec' points inwards from the polygons vertex. the vertex is identified by its index
	within the ordered collection 'vertices'. note, that for hollow polygons (cw winding order) 'inwards' is actually
	inverted."
	| iLeft iRight u v aU aV aP |
	iLeft := self indexLeftOf: index.
	iRight := self indexRightOf: index.
	
	"vector from the current point to the left neighbor"
	u := (vertices at: iLeft) - (vertices at: index).
	
	"vector from the current point to the right neighbor"
	v := (vertices at: iRight) - (vertices at: index).
	
	aU := u angle.
	aV := v angle.
	aP := vec angle.
	aU < 0 ifTrue: [aU := aU + (Float twoPi)].
	aV < 0 ifTrue: [aV := aV + (Float twoPi)].
	aP < 0 ifTrue: [aP := aP + (Float twoPi)].
	
	"debug message
	Transcript show: ((vertices at: iLeft) point) printString, '-->',((vertices at: index) point) printString, '-->', ((vertices at: iRight) point) printString, '  ',
		' u=', u printString, ' (', (aU printShowingDecimalPlaces: 3), '), ',
		' v=', v printString, ' (', (aV printShowingDecimalPlaces: 3), '), ',
		' p=', (vec printString), ' (', (aP printShowingDecimalPlaces: 3), ')  '.
	"
	
	aU < aV ifTrue: [
		"the angle of the left neighbor is smaller than the angle of the right neighbor"
		(aP >= aU) & (aP <= aV) ifTrue: [
			"aP lies in between aU and aV, therefore pointing inwards
			Transcript show: 'out (a)'; cr."
			^false.
		] ifFalse: [
			"
			Transcript show: 'in (b)'; cr."
			^true.
		]
	] ifFalse: [
		"the angle of the right neighbor is smaller than the angle of the left neighbor"
		(aP > aV) & (aP < aU) ifTrue: [
			"aP lies in between aV and aU, therefore pointing outwards
			Transcript show: 'in (c)'; cr."
			^true.
		] ifFalse: [
			"
			Transcript show: 'out (d)'; cr."
			^false.
		].
	].
	

]

{ #category : #printing }
VMClosedPolygon >> printString [
	"creates a string witch shows the indices of the vertices, as well as the polygons winding order"
	| vertexString cwString |
	
	vertexString := ''.
	
	cw ifTrue: [
		cwString := 'cw'.
	] ifFalse: [
		cwString := 'ccw'.
	].
	
	vertices do: [ :v |
		"vertexString := vertexString, '(', (v x)printString, ' / ', (v y)printString, ') '."
		vertexString := vertexString, (v index)printString, ' '.
	].
	^vertexString, cwString.
]

{ #category : #printing }
VMClosedPolygon >> printStringEx [
	"creates a string witch shows the coordinates, indices and ids of the vertices, as well as the polygons bounding box and winding order"
	| vertexString cwString boundsString |
	
	vertexString := ''.
	
	self testCW ifTrue: [
		cwString := 'cw'.
	] ifFalse: [
		cwString := 'ccw'.
	].
	
	vertices do: [ :v |
		vertexString := vertexString, '(', (v x)printString, ' @ ', (v y)printString, ', i=', (v index)printString, ' id=', (v id)printString ,') '.
	].
	
	boundsString := 't=', maxY printString, ' r=', maxX printString, ' b=', minY printString, ' l=', minX printString, ' '.
	
	^vertexString, boundsString, cwString.
]

{ #category : #'winding order' }
VMClosedPolygon >> setWindingOrderByOrigin: aPoint [
	"Transcript show: 'origin:', aPoint asPoint printString; cr."
	(self isPointInside: aPoint)
		ifTrue: [ self makeCW. ]
		ifFalse: [ self makeCCW. ].

]

{ #category : #testing }
VMClosedPolygon >> testCW [
	"tests the winding order of the polygon."
	
	| point index iLeft iRight pLeft pRight dxLeft dyLeft dxRight dyRight aLeft aRight |
	
	point  := vertices first.
	index := 1.
	
	"select the point with the highest y value. if there are multiple choises, we choose the right-most one"
	vertices doWithIndex: [ :p :i |
		((p y) >= (point y)) ifTrue: [
			(p y) > point y ifTrue: [ point := p. index := i. ].
			
			(point x) < (p x) ifTrue: [ point := p. index := i. ].
		].
	].
	
	"get the left and right neighbor of the selected point"
	iLeft := index -1.
	iLeft < 1 ifTrue: [ iLeft := vertices size. ].
	iRight := index + 1.
	iRight > (vertices size) ifTrue: [ iRight := 1 ].
	
	pLeft := vertices at: iLeft.
	pRight := vertices at: iRight.
	
	dxLeft := (point x) - (pLeft x).
	dyLeft := (point y) - (pLeft y).
	dxRight := (point x) - (pRight x).
	dyRight := (point y) - (pRight y).
	
	self logCr:
		'testCW point=', (point point)printString,
		', left=', (pLeft point)printString,
		', right=', (pRight point)printString,
		', dxLeft=', dxLeft printString,
		' dxRight=', dxRight printString,
		', dyLeft=', dyLeft printString,
		' dyRight=', dyRight printString.
	
	"handle the special case where the left neighbor has no change in x"
	dxLeft = 0 ifTrue: [
		dxRight < 0 ifTrue: [
			self  logCr: 'true (1)'.
			^true.
		].
		self  logCr: 'false (2)'.
		^false.
	].
	
	"handle the special case where the right neighbor has no change in x"
	dxRight = 0 ifTrue: [
		^false.
		"dxLeft > 0 ifTrue: [
			self  logCr: 'true (3)'.
			^true.
		].
		self  logCr: 'false (4)'.
		^false."
	].
	
	"compute the slope of the two neighbors and compare them"
	aLeft := dyLeft/dxLeft.
	aRight := dyRight/dxRight.
	
	(aLeft = 0) ifTrue: [ self logCr: 'true (0 left)'. ^true. ].
	(aRight = 0) ifTrue: [ self logCr: 'false (0 right)'. ^false. ].
	
	(aLeft sign) = (aRight sign) ifTrue: [
		(aLeft < aRight) ifTrue: [
			self  logCr: 'true (5)'.
			^true.
		].
		self  logCr: 'false (6)'.
		^false.
	] ifFalse: [
		(aLeft > aRight) ifTrue: [
			self  logCr: 'true (7)'.
			^true.
		].
		self  logCr: 'false (8)'.
		^false.
	].





]

{ #category : #testing }
VMClosedPolygon >> windingNumber: p [
	"computes the winding number for a point with respect to the polygon. does only make sense if we have a closed polygon."
	| wn length fun |
	
	wn := 0.
	length := vertices size.
	
	fun := [ :a :b |
		(a y) > (p y) ifTrue: [
			"a is located above p"
			(b y) > (p y) ifTrue: [
				"a and b are both located above p. the winding number does not change"
			] ifFalse: [
				"a is above p and b is below. the winding number changes if p lies to the left of the line a->b."
				(self isLeft: p a: a b: b) ifTrue: [
					wn := wn + 1.
				]
			]
		] ifFalse: [
			"a is located below p"
			(b y) > (p y) ifTrue: [
				"a is below p and b is above p. the winding number changes if p lies to the left of the line a->b."
				(self isLeft: p a: a b: b) ifTrue: [
					wn := wn - 1.
				].
			] ifFalse: [
				"a and b are both located below p. the winding number does not change"
			].
		].
	].

	"iterate over all but the last vertex. the last vertex is treated seperatly because it is connected with the first one"
	1 to: (length-1) do: [ :i |
		fun value: (vertices at: i) value: (vertices at: (i+1)).
	].
	
	fun value: (vertices last) value: (vertices first).
	
	^wn.
]
