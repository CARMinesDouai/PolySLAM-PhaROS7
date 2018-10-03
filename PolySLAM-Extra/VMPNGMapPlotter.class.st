Class {
	#name : #VMPNGMapPlotter,
	#superclass : #VMBSPTreePlotter,
	#instVars : [
		'tf'
	],
	#category : #'PolySLAM-Extra-Gnuplot plotter'
}

{ #category : #plotting }
VMPNGMapPlotter >> plotLeaf: node [
	node isLeaf ifTrue: [
		node sector isNotNil ifTrue: [
			| copy |
			copy := tf ifNil: [ node sector ] ifNotNil: [ node sector transform: tf ].
			
			self plotFilledPolygon: copy extra: 'lc rgb "#FFFFFF"'.
			showArrowHeads
				ifTrue: [ self plotArrowCollection: copy. ]
				ifFalse: [ self plotHeadlessArrowCollection2: copy. ].
		].
	].

]

{ #category : #accessing }
VMPNGMapPlotter >> tf: aVMTFMatrix [
	tf := aVMTFMatrix.
]
