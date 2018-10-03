Class {
	#name : #VMScan2DData,
	#superclass : #Object,
	#instVars : [
		'tf',
		'collection',
		'timestamp'
	],
	#category : #'PolySLAM-Extra-Simulator'
}

{ #category : #'as yet unclassified' }
VMScan2DData class >> rendererClass [
	^ VMScanDataRenderer 
]

{ #category : #'as yet unclassified' }
VMScan2DData >> add: point [
	collection add: point
]

{ #category : #'as yet unclassified' }
VMScan2DData >> asRenderableElement [
	^ self class rendererClass new model: self
]

{ #category : #'as yet unclassified' }
VMScan2DData >> center [
	"returns the position of the scanner. the data being in the scanners local frame, the scanner is naturaly located at 0@0"
	^ (0@0).
]

{ #category : #'as yet unclassified' }
VMScan2DData >> collection [
	^collection.
]

{ #category : #'as yet unclassified' }
VMScan2DData >> initialize [
	timestamp := 0.
	collection := OrderedCollection new.
	tf := VMTransformationFrame new.
]

{ #category : #'as yet unclassified' }
VMScan2DData >> tf [
	^tf.
]

{ #category : #'as yet unclassified' }
VMScan2DData >> tf: frame [
	tf := frame.
]

{ #category : #'as yet unclassified' }
VMScan2DData >> timestamp [
	^timestamp.
]

{ #category : #'as yet unclassified' }
VMScan2DData >> timestamp: time [
	timestamp := time.
]
