"
This class handles visualization of the VMMapMerger class instance.

color scheme:
	- orange: global map
	- blue: full overlapping line segments
	- cyan: partial overlapping line segments
	- magenta: partial overlapping line segment's partner
	- green: none-overlapping line segments
"
Class {
	#name : #VMMapMergerRenderer,
	#superclass : #VMFigureRenderer,
	#instVars : [
		'showGlobalMap',
		'showFullOverlaps',
		'showPartialOverlaps',
		'showNoOverlaps',
		'showPartialPairs'
	],
	#category : #'PolySLAM-Extra-GUI-Athens'
}

{ #category : #initialization }
VMMapMergerRenderer >> initialize [
	super initialize.
	
	showLabel := false.
	
	showGlobalMap := true.
	showFullOverlaps := true.
	showPartialOverlaps := true.
	showNoOverlaps := true.
	showPartialPairs := false.

]

{ #category : #rendering }
VMMapMergerRenderer >> renderOn: canvas [
	
	showGlobalMap ifTrue: [
		(model globalMap asRenderableElement)
			colorObstacle: Color red frontier: Color orange;
			renderOn: canvas.
	].
	
	showFullOverlaps ifTrue: [ self renderLineCollection: model listFullOverlap color: Color blue on: canvas. ].
	
	showPartialOverlaps ifTrue: [
		model listPartialOverlap ifNotNil: [
			self renderLineCollection: (model listPartialOverlap collect: [ :obj | obj first]) color: Color cyan on: canvas.
		].
	].
	
	showNoOverlaps ifTrue: [ self renderLineCollection: model listNoOverlap color: Color green on: canvas. ].
	
	showPartialPairs ifTrue: [
		model listPartialOverlap ifNotNil: [
			self renderLineCollection: (model listPartialOverlap collect: [ :obj | obj first]) color: Color cyan on: canvas.
		].
		model listPartialOverlap ifNotNil: [
			self renderLineCollection: (model listPartialOverlap collect: [ :obj | obj second]) color: Color magenta on: canvas.
		].
	].
	
	
	"super renderOn: canvas.
	"
]

{ #category : #accessing }
VMMapMergerRenderer >> showFullOverlaps: aBoolean [
	showFullOverlaps := aBoolean.
]

{ #category : #accessing }
VMMapMergerRenderer >> showGlobalMap: aBoolean [
	showGlobalMap := aBoolean.
]

{ #category : #accessing }
VMMapMergerRenderer >> showNoOverlaps: aBoolean [
	showNoOverlaps := aBoolean.
]

{ #category : #accessing }
VMMapMergerRenderer >> showPartialOverlaps: aBoolean [
	showPartialOverlaps := aBoolean.
]

{ #category : #accessing }
VMMapMergerRenderer >> showPartialPairs: aBoolean [
	showPartialPairs := aBoolean
]
