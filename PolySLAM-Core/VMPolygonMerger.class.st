Class {
	#name : #VMPolygonMerger,
	#superclass : #Object,
	#instVars : [
		'startVertex',
		'lineSegs',
		'startLineSeg',
		'prevLineSeg',
		'mergedPolgonVertices',
		'maxIterations',
		'iterationCounter'
	],
	#category : #'PolySLAM-Core-kernel'
}

{ #category : #'as yet unclassified' }
VMPolygonMerger class >> merge: polygonCollection [
	^(self new)
		compute: polygonCollection.
]

{ #category : #initialize }
VMPolygonMerger >> compute: polygonCollection [
	
	self setup: polygonCollection.
		
	^self merge applyAutoId;
		yourself.

]

{ #category : #merging }
VMPolygonMerger >> computeIntersections: lineSeg lineSegs: lineSegCollection [
	"computes the intersections between lineSeg and all line segments in lineSegCollection. we are looking for the intersection closest to the start point of lineSeg.
	
	we return an OrderedCollection that contains an Array with the vertex of the intersection, the relative distance (as a factor), and the line segment that
	intersected with lineSeg. if multiple intersections are equally closest to lineSeg's starting point, the returned OrderedCollection contains multiple arrays."
	| results factor epsilon |
	
	results := OrderedCollection new.
	factor := 2.0.		"the current distance (as a factor in the range of 0 to 1) of the intersection closest to the starting point of the line segment 'cur'."
	epsilon := 0.000001.
	
	"compute intersections with our current line segment 'cur'."
	lineSegCollection do: [ :ls |
		lineSeg ifStrictIntersectsWith: ls do: [ :p :f |
			f > epsilon ifTrue: [
				Transcript show: 'intersection f=', f printString, ' p=', p printString, '(',ls pointA printPoint, ' / ', ls pointB printPoint,')'; cr.
				
				(f = factor) ifTrue: [ results add: { p. f. ls. }. ].
				(f < factor) ifTrue: [ factor := f. results removeAll. results add: { p. f. ls. }. ].
			].
		].
	].

	^results.
		

]

{ #category : #'as yet unclassified' }
VMPolygonMerger >> getNextLineSeg [
	| vertex intersections prevAngle result greatesDeltaAngle |
	
	vertex := prevLineSeg pointB.
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

{ #category : #'as yet unclassified' }
VMPolygonMerger >> handleIntersections: intersections [
	intersections ifEmpty: [
		self logCr: iterationCounter printString, ': empty intersections collection'.
		
		(prevLineSeg pointB) = startVertex ifTrue: [
			^VMClosedPolygon fromOrderedVertices: mergedPolgonVertices.
		].
		
		mergedPolgonVertices add: (prevLineSeg pointB).
		
		prevLineSeg := self getNextLineSeg.
	] ifNotEmpty: [
		| intersectionsResult |
		self logCr: iterationCounter printString, ': not empty (size=', intersections size printString ,') ',(intersections first at: 1)printString, (intersections first at: 2)printString.
		"for testing, we currently just take the first result, even if we have multiple equal results"
		intersectionsResult := self selectIntersectionsResult: intersections.
		"self assert: (intersections size = 1)."
		
		mergedPolgonVertices add: (VMGraphVertex point: (intersectionsResult at: 1)).
		prevLineSeg := VMLineSegment from: (intersectionsResult at: 1) to: ((intersectionsResult at: 3) pointB).
	].

]

{ #category : #actions }
VMPolygonMerger >> merge [
	
	"while developing and debugging, we limit the number of iterations to prevent unintential infinit loops to runn amok.
	this limit should be set to a much higher number or completly removed when all tests are implemented and passed."
	maxIterations := 14.
	iterationCounter := 0.
	
	mergedPolgonVertices add: startVertex.
	
	"note: the loop abort condition (aside from the counter) is to reach the start vertex 'start' without any further splitting of the 'cur' line segment."
	[ maxIterations > iterationCounter ] whileTrue: [
		| intersections |
		
		iterationCounter := iterationCounter + 1.
		
		intersections := self computeIntersections: prevLineSeg lineSegs: lineSegs.
		
		self handleIntersections: intersections.
	].
	
	self assert: (mergedPolgonVertices size > 2).
	
	self logCr: 'iterations=', iterationCounter printString, ' (max=', maxIterations printString, ')'.
	^VMClosedPolygon fromOrderedVertices: mergedPolgonVertices.























]

{ #category : #'as yet unclassified' }
VMPolygonMerger >> selectIntersectionsResult: intersections [
	"NOTE: this code does not handle cases where two or more intersections share the same 'best' angle. in that case it simply returns the first 'best' result."
	| prevLineSegAngle currentGreatestAngle currentIndex angleOffset |
	
	prevLineSegAngle := prevLineSeg copy inverse angle.
	angleOffset := Float twoPi - prevLineSegAngle.
	currentGreatestAngle := -1.0.
	currentIndex := 1.
	
	intersections doWithIndex: [ :entry :index |
		| angle |
		angle := (entry at: 3) angle + angleOffset.
		angle >= Float twoPi ifTrue: [
			angle := angle - Float twoPi.
		].
		angle > currentGreatestAngle ifTrue: [
			currentGreatestAngle := angle.
			currentIndex := index.
		].
	].
	
	^intersections at: currentIndex.
]

{ #category : #'class initialization' }
VMPolygonMerger >> setup: polygons [
	startVertex := polygons first vertices first.
	startLineSeg := nil.
	lineSegs := OrderedCollection new.
	mergedPolgonVertices := OrderedCollection new.
	"prevLineSeg := nil."
	
	polygons do: [ :p |
		p vertices doWithIndex: [ :v :i |
			| line |
			"create a line segment and store it"
			line := VMLineSegment from: v to: (p vertices atWrap: (i+1)).
			lineSegs add: line.
			
			"check if the vertex is further to the right then 'start'. if both have the same x value, we choose the one with the higher y value"
			(startVertex x) < (v x) ifTrue: [ startVertex := v. startLineSeg := line. ].
			(startVertex x) = (v x) ifTrue: [
				(startVertex y) < (v y) ifTrue: [ startVertex := v. startLineSeg := line. ].
			].
		].
	].
	Transcript show: 'start=', startVertex printPoint, ' ', self printString; cr.
	
	"the only possible reason why 'startLineSeg' could be nil is, that our very first vertex already was
	the right-most vertex. in that case, the first element in 'lineSegs' is the correct starting lineSeg."
	startLineSeg ifNil: [ startLineSeg := lineSegs first. ].
	
	prevLineSeg := startLineSeg.
	

]
