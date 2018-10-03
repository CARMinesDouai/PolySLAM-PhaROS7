Class {
	#name : #VMLocalMap,
	#superclass : #Object,
	#instVars : [
		'lineSegments',
		'tf',
		'obstacleDist'
	],
	#category : #'PolySLAM-Core-SLAM - Maps'
}

{ #category : #constructor }
VMLocalMap class >> lineSegments: aCollection [
	^self new lineSegments: aCollection asOrderedCollection.
]

{ #category : #'rendering support' }
VMLocalMap class >> rendererClass [
	^VMLocalMapRenderer.
]

{ #category : #'as yet unclassified' }
VMLocalMap >> applyTransform: aVMTFMatrix [
	lineSegments do: [ :lineSeg |
		lineSeg applyTransform: aVMTFMatrix.
	].
]

{ #category : #converting }
VMLocalMap >> asPointCollection [
	| col |
	
	col := OrderedCollection new.
	lineSegments do: [ :lineSeg |
		col add: lineSeg pointA.
	].
	
	^ col
]

{ #category : #converting }
VMLocalMap >> asPolygonCollection [
	| collection |
	
	collection := VMPolygonCollection new.
	collection add: VMPolygon new.
	collection first add: lineSegments first.
	
	lineSegments allButFirstDo: [ :vec |
		(vec pointA = collection last last pointB) ifFalse: [ collection add: VMPolygon new. ].
		collection last add: vec.
	].

	^ collection
]

{ #category : #converting }
VMLocalMap >> asRenderableElement [
	^ self class rendererClass new model: self
]

{ #category : #accessing }
VMLocalMap >> bounds [
	| rect |
	
	lineSegments ifEmpty: [ ^nil ].
	
	rect := lineSegments first bounds.
	
	lineSegments do: [ :lineSeg |
		rect := rect merge: lineSeg bounds.
	].

	^rect

]

{ #category : #construction }
VMLocalMap >> fromKeyFrame: keyFrame [
	| collection sensorCenter |
	tf := keyFrame location frame.
	
	"for now we assume a single LRF sensor"
	collection := keyFrame data first collection.
	
	"code connecting all edges, but not warping. first and  last are connected with the center of the sensor"
	1 to: ((collection size) -1 ) do: [ :index |
		| dist vertex |
		vertex := collection at: index.
		dist := vertex dist: (collection at: (index+1)).
		(dist >= obstacleDist) ifTrue: [
			"considered a frontier"
			lineSegments add: (VMLineSegment from: vertex to: (collection at: (index+1)) type: (VMLineTypeFrontier new)).
		] ifFalse: [
			"considered an obstacle"
			lineSegments add: (VMLineSegment from: vertex to: (collection at: (index+1)) type: (VMLineTypeObstacle new)).
		].
	].
	sensorCenter := 0@0.
	lineSegments add: (VMLineSegment from: (collection last) to: sensorCenter type: (VMLineTypeFrontier new)).
	lineSegments add: (VMLineSegment from: sensorCenter to: (collection first) type: (VMLineTypeFrontier new)).
	
	
]

{ #category : #construction }
VMLocalMap >> fromPointCloud: pc tf: aTransform [
	"note: aTransform provides the transformation for the sensor center. the 'tf' of
	the map is set to identity for the time being. this behaviour might be changed
	later."
	| collection sensorCenter pointA pointB first last |
	"tf := VMTFMatrix identity."
	tf := aTransform.
	
	collection := pc points.
	collection ifEmpty: [ ^self. ].
	
	first := aTransform transformPoint: collection first.
	last := aTransform transformPoint: collection last.
	
	pointB := first. "we need a valid 'pointB' before entering the loop below"
	
	"code connecting all edges, but not warping. first and last are connected with the center of the sensor after this loop"
	collection allButFirstDo: [ :aPoint |
		| dist type |
		
		pointA := pointB. "the start of the next line segment is the end point of the last one"
		pointB := aTransform transformPoint: aPoint.
		
		dist := pointA dist: pointB.
		
		type := (dist >= obstacleDist) ifTrue: [ VMLineTypeFrontier new ] ifFalse: [ VMLineTypeObstacle new ].
		lineSegments add: (VMLineSegment from: pointA to: pointB type: type).
	].

	sensorCenter := aTransform transformPoint: pc sensorCenter.
	
	lineSegments add: (VMLineSegment from: last to: sensorCenter type: (VMLineTypeFrontier new)).
	lineSegments add: (VMLineSegment from: sensorCenter to: first type: (VMLineTypeFrontier new)).
	
	
]

{ #category : #construction }
VMLocalMap >> fromVMMapMsg: aVMMapMsg [
	"aVMMapMsg is a ROS message of the type vector_map/vm_map"
	| vertexCount |
	vertexCount := aVMMapMsg vertices size.
	
	self assert: ((vertexCount \\ 2) == 0).
	
	1 to: aVMMapMsg vertices size by: 2 do: [ :index |
		| vertex pointA pointB type |
		
		vertex := aVMMapMsg vertices at: index.
		pointA := ((vertex x) @ (vertex y)).
		type := VMLineType fromInteger: vertex type.
		
		vertex := aVMMapMsg vertices at: (index + 1).
		pointB := ((vertex x) @ (vertex y)).
		
		lineSegments add: (VMLineSegment from: pointA to: pointB type: type).
	].

]

{ #category : #'import / export' }
VMLocalMap >> fromVertexString: aString [
	| lines |
	
	lines := Character lf split: aString.
	
	lines do: [ :aLine |
		| numbers |
		((aLine size > 0) and: [(aLine at:1) ~= $# ]) ifTrue: [
			numbers := Character space split: aLine.
		
			lineSegments add:
				(VMLineSegment
					from: (numbers first asNumber @ numbers second asNumber)
					to: (numbers third asNumber @ numbers fourth asNumber)
					type: (numbers fifth asInteger)
				).
		].
	].
	
	
	

]

{ #category : #initialization }
VMLocalMap >> initialize [
	obstacleDist := 0.5. "unit: meter"
	lineSegments := OrderedCollection new.
	tf := VMTransformationFrame new.
]

{ #category : #accessing }
VMLocalMap >> lineSegments [
	^lineSegments.
]

{ #category : #accessing }
VMLocalMap >> lineSegments: aCollection [
	lineSegments := aCollection.
]

{ #category : #'import / export' }
VMLocalMap >> load: filename [
	"creates a new instance from a file created via the 'save' method"
	| file handle data |
	
	file := File named: filename.
	handle := file openForRead.
	data := handle upToEnd asString.
	handle close.
	
	^self readFromString: data.
	
	

]

{ #category : #accessing }
VMLocalMap >> obstacleDist [
	^obstacleDist.
]

{ #category : #accessing }
VMLocalMap >> obstacleDist: aNumber [
	obstacleDist := aNumber.
]

{ #category : #printing }
VMLocalMap >> printFullString [
	"this method prints the full content of the local map into a single string.
	since local maps can grow quite a bit, this string can become quite long
	itself."
	| string |
	
	string := 'VMLocalMap lineSegments: { '.
	lineSegments do: [ :lineSeg |
		string := string, lineSeg printString, '. '.
	].
	
	string := string, '}'.
	
	^string.

]

{ #category : #printing }
VMLocalMap >> printString [
	"a short version, since we often don't care too much about individual line segments."
	| string |
	
	string := 'VMLocalMap (lineSegCount=', lineSegments size printString, ', tf=', tf printString, ')'.
	
	^string.

]

{ #category : #'import / export' }
VMLocalMap >> printVertexString [
	"returns a string which contains one line segment per line. the line segment is
	defined as a tupel of 5 numbers (start coords, end corrds, and type). The
	numbers are seperated by a single whitespace character."
	| string |
	
	string := ''.
	
	lineSegments do: [ :lineSeg |
		string := string,
			lineSeg pointA x printString,
			' ', lineSeg pointA y printString,
			' ', lineSeg pointB x printString,
			' ', lineSeg pointB y printString,
			' ', lineSeg type asInteger printString,
			String lf.
	].
	
	^string.
	
]

{ #category : #reading }
VMLocalMap >> readFromString: aString [ 
	"Create an object based on the contents of aString."
	^ self class readFrom: aString readStream
]

{ #category : #'import / export' }
VMLocalMap >> save: filename [
	"saves the object instance using the storeString 'method'"
	| file handle |
	
	file := File named: filename.
	
	handle := file openForWrite.
	handle truncate.
	
	handle nextPutAll: self storeString.
	handle close.
	
	

]

{ #category : #'import / export' }
VMLocalMap >> saveAsVerticesInFile: filename [
	"saves the object instance using the storeString 'method'"
	| file handle |
	
	file := File named: filename.
	
	handle := file openForWrite.
	handle truncate.
	
	handle nextPutAll: self printVertexString.
	
	handle close.
	
	

]

{ #category : #'as yet unclassified' }
VMLocalMap >> simplify [
	| simplifier |
	
	simplifier := VMLocalMapSimplifier new.
	simplifier maxError: 0.002.
	
	self lineSegments: (simplifier simplify: lineSegments).

]

{ #category : #accessing }
VMLocalMap >> tf [
	^tf.
]

{ #category : #accessing }
VMLocalMap >> tf: aFrame [
	tf := aFrame.
]

{ #category : #accessing }
VMLocalMap >> transform: aVMTFMatrix [
	^ self species lineSegments: (lineSegments collect: [:ls | ls transform: aVMTFMatrix])

]

{ #category : #'import / export' }
VMLocalMap >> writeToFile: filename [
	| file handle |
	
	file := File named: filename.
	
	handle := file openForWrite.
	handle truncate.
	
	handle nextPutAll: self printFullString.
	
	handle close.
	

]
