Class {
	#name : #PSMapping,
	#superclass : #Object,
	#instVars : [
		'map',
		'polygons',
		'running'
	],
	#category : #'PolySLAM-Pipeline-Core'
}

{ #category : #accessing }
PSMapping >> addPolygon: p [
	polygons nextPut: p
]

{ #category : #initialization }
PSMapping >> initialize [
	super initialize.
	polygons := SharedQueue new.
	running := false.
	map := VMBSPLeaf new. 
]

{ #category : #accessing }
PSMapping >> map [
	^ map
]

{ #category : #accessing }
PSMapping >> map: anObject [
	map := anObject
]

{ #category : #process }
PSMapping >> process [
	|polygon|
	[ running ] whileTrue: [ 
		polygons atEnd ifFalse:[
			polygon := polygons next.
			"[	"
				VMBSPLeaf new insert: polygon.
				map := map insert: polygon.
				map inspect.
				self halt.
			"] on: Error do: [ Transcript show: ' Error on adding polygon'; cr ]. "
		]
	]
]

{ #category : #process }
PSMapping >> start [
	running := true.
	[ self process ] forkAt: Processor userBackgroundPriority 
]

{ #category : #process }
PSMapping >> stop [
	running := false
]
