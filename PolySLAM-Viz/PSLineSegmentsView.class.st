Class {
	#name : #PSLineSegmentsView,
	#superclass : #RHModule,
	#instVars : [
		'lines',
		'line_color',
		'queue'
	],
	#category : #'PolySLAM-Viz'
}

{ #category : #drawing }
PSLineSegmentsView >> canvasPos: realPost [
	^((realPost x) / self parent resolution) rounded @ ( 0 - ( (realPost y) / self parent resolution)) rounded.
]

{ #category : #drawing }
PSLineSegmentsView >> cleanup [
	lines do:[:s| self canvas removeShape: s].
]

{ #category : #sync }
PSLineSegmentsView >> desynchronize [
	self lock critical: [
		self cleanup.
		self canvas signalUpdate
	].
	self announcer unsubscribe: self
]

{ #category : #drawing }
PSLineSegmentsView >> draw: aCollection [
	|collection shape|
	collection := OrderedCollection new.
	collection := aCollection select: [ :e| e isObstacle  ] thenCollect: [ :line|
		shape := TRLineShape new from: (self canvasPos: line pointA) to: (self canvasPos: line pointB).
		shape color: (self line_color ).
		shape
	].

	self lock critical: [ 
		"self cleanup."
		collection do:[:e| lines add:e.self canvas addShape: e].
		self canvas signalUpdate
	].
]

{ #category : #initialization }
PSLineSegmentsView >> initialize [
	super initialize.
	lines := OrderedCollection new.
	line_color := Color red.
	queue := SharedQueue new.
]

{ #category : #accessing }
PSLineSegmentsView >> line_color [
	<galleonProperty: #Color>
	^ line_color
]

{ #category : #accessing }
PSLineSegmentsView >> line_color: anObject [
	line_color := anObject
]

{ #category : #accessing }
PSLineSegmentsView >> name [
	^ 'Line segments view'
]

{ #category : #sync }
PSLineSegmentsView >> synchronize [
	self announcer when: LineSegmentsDataEvent do:[:e| self draw:e data].
]
