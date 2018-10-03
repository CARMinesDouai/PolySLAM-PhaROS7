Class {
	#name : #VMSimulator,
	#superclass : #Object,
	#instVars : [
		'timestamp',
		'objectCollection',
		'tf',
		'map'
	],
	#category : #'PolySLAM-Extra-Simulator'
}

{ #category : #adding }
VMSimulator >> add: anObject [
	objectCollection add: anObject.
]

{ #category : #adding }
VMSimulator >> addAll: aCollection [
	objectCollection addAll: aCollection.
]

{ #category : #initialization }
VMSimulator >> initialize [
	timestamp := 0.0.
	objectCollection := Set new.
	tf := (VMTransformationFrame new)
		id: 'world'.
	
	map := nil.
]

{ #category : #accessing }
VMSimulator >> map [
	^map.
]

{ #category : #accessing }
VMSimulator >> map: aMap [
	"set the global (true) map"
	map := aMap.
]

{ #category : #adding }
VMSimulator >> objects: aCollection [
	objectCollection addAll: aCollection.
]

{ #category : #spinning }
VMSimulator >> spinOnce [
	objectCollection do: [ :obj |
		obj spinOnce.
	].
]
