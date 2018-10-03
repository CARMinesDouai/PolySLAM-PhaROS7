Class {
	#name : #VMTFMatrixTests,
	#superclass : #VMTests,
	#category : #'PolySLAM-Tests'
}

{ #category : #'as yet unclassified' }
VMTFMatrixTests >> testAngle [
	| mat data epsilon |
	
	mat := VMTFMatrix zeros.
	epsilon := 0.000001.
	
	data := {
		0.0.
		0.123 * Float pi.
		Float halfPi.
		Float halfPi negated.
		-0.3.
	}.
	
	data do: [ :theta |
		mat angle: theta.
		self assert: ((mat angle - theta) abs < epsilon).
	].

]

{ #category : #'as yet unclassified' }
VMTFMatrixTests >> testInverse [
	| matA matB matC identity angle shift epsilon |
	
	epsilon := 0.000001.
	angle := 0.234 * (Float pi).
	shift := 1@3.
	
	matA := VMTFMatrix r: (VMMatrix2d angle: angle) t: (VMVector2d point: shift).
	matB := matA inverse.
	
	matC := matA * matB.
	identity := VMTFMatrix identity.
	
	matC indicesDo: [ :row :column |
		self assert: (  ((matC at: row at: column) - (identity at: row at: column)) abs < epsilon  ).
	].
]
