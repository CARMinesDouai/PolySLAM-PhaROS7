"
Singular Value Decomposition

This class computes the singular value compostion for 2x2 Matrices that have real-only eigen values.



Public API and Key Messages

- matrix: <DhbMatrix (2x2)>
	computes the SVD for the provided matrix
	
- u
	returns the matrix U from the SVD
	
- s
	returns the matrix sigma from the SVD
	
- v
	returns the matrix V^T from the SVD



"
Class {
	#name : #VMSVD,
	#superclass : #Object,
	#instVars : [
		'u',
		's',
		'v'
	],
	#category : #'PolySLAM-Core-LinAlgebra'
}

{ #category : #'as yet unclassified' }
VMSVD class >> matrix: m [
	^(self new)
		matrix: m;
		yourself.
]

{ #category : #creation }
VMSVD >> matrix: m [
	| mTm mmT eigen |
	
	mTm := m transpose * m.
	mmT := m * (m transpose).
	
	eigen := VMEigen2d matrix: mmT.
	u := DhbMatrix rows: 2 columns: 2.
	u at: 1 at: 1 put: (eigen vector1 x).
	u at: 1 at: 2 put: (eigen vector1 y).
	u at: 2 at: 1 put: (eigen vector2 x).
	u at: 2 at: 2 put: (eigen vector2 y).
	
	s := DhbMatrix rows: 2 columns: 2.
	s at: 1 at: 1 put: (eigen value1 sqrt).
	s at: 1 at: 2 put: 0.
	s at: 2 at: 1 put: 0.
	s at: 2 at: 2 put: (eigen value2 sqrt).
	
	eigen := VMEigen2d matrix: mTm.
	v := DhbMatrix rows: 2 columns: 2.
	v at: 1 at: 1 put: (eigen vector1 x).
	v at: 1 at: 2 put: (eigen vector1 y).
	v at: 2 at: 1 put: (eigen vector2 x).
	v at: 2 at: 2 put: (eigen vector2 y).

]

{ #category : #accessing }
VMSVD >> s [
	^s.
]

{ #category : #accessing }
VMSVD >> u [
	^u.
]

{ #category : #accessing }
VMSVD >> v [
	^v.
]
