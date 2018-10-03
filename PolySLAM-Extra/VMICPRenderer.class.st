Class {
	#name : #VMICPRenderer,
	#superclass : #VMBaseRenderer,
	#instVars : [
		'showMatchHistory'
	],
	#category : #'PolySLAM-Extra-GUI-Athens'
}

{ #category : #initialization }
VMICPRenderer >> initialize [
	super initialize.
	showMatchHistory := true.
]

{ #category : #rendering }
VMICPRenderer >> renderMatchHistoryOn: aCanvas [
	| originalLineWidth |
	
	originalLineWidth := lineWidth.
	lineWidth := 0.75*lineWidth.
	
	model matchHistory doWithIndex: [ :matches :index |
		| rColor t |
		t := index / (model matchHistory size).
		rColor := index = 1
			ifTrue: [ Color h: 50 s: 1 v: 1 ]
			ifFalse: [ Color h: 45*(1-t) s: 1 v: 1 alpha: 0.3 ].
		index = model matchHistory size ifTrue: [ rColor := Color red ].
		
		matches do: [ :pair |
			((pair first isNotNil) and: pair second isNotNil) ifTrue: [
				self renderPoint: pair first radius: lineWidth on: aCanvas color: rColor.
				self renderPoint: pair second radius: lineWidth on: aCanvas color: rColor.
				
				self renderStyledLineSegFrom: pair first to: pair second on: aCanvas color: rColor
			].
		].
	].
	
	lineWidth := originalLineWidth.

]

{ #category : #rendering }
VMICPRenderer >> renderOn: aCanvas [
	model ifNil: [ ^self ].
	
	"(VMPointCollectionRenderer new model: model nnCollection)"
	(model nnCollection asRenderableElement)
		lineWidth: lineWidth;
		color: Color blue;
		renderOn: aCanvas.
	
	model collectionHistory doWithIndex: [ :pc :index |
		| rColor t |
		t := index / (model collectionHistory size).
		rColor := index = 1
			ifTrue: [ Color h: 50 s: 1 v: 1 ]
			ifFalse: [ Color h: 45*(1-t) s: 1 v: 1 alpha: 0.3 ].
		index = model collectionHistory size ifTrue: [ rColor := Color red ].
			
		(VMPointCollectionRenderer new model: pc)
			lineWidth: lineWidth;
			color: rColor;
			renderOn: aCanvas.
	].
	
	showMatchHistory ifTrue: [ self renderMatchHistoryOn: aCanvas. ].
]

{ #category : #accessing }
VMICPRenderer >> showMatchHistory: boolean [
	showMatchHistory := boolean
]
