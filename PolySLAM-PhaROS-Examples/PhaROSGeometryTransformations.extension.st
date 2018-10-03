Extension { #name : #PhaROSGeometryTransformations }

{ #category : #'*PolySLAM-PhaROS-Examples' }
PhaROSGeometryTransformations >> quaternationFromEuler: anEulerTuple [ 
 | i j k matrix cosins sins cisk cick sisk sick |

"
i versor is related to x 
j versor is related with y
k versor is related with z
"

	i := 1.
	j := 2.
	k := 3.
	
		
	matrix :=anEulerTuple collect: [ :it | it / 2.0].
	cosins := matrix collect: [ :it | it cos ].
	sins := matrix collect: [:it | it sin].
	

     cick := (cosins at: i) * (cosins at:k).
     cisk := (cosins at: i )* (sins at:k).
     sick := (sins at: i )* (cosins at:k).
     sisk := (sins at: i )* (sins at:k).
	
	
	^ 
	{ 
		((cosins at: j) * sick) - ((sins at: j )* cisk).
		((cosins at: j) * sisk) - ((sins at: j )* cick).
		((cosins at: j) * cisk) - ((sins at: j )* sick).
		((cosins at: j) * cick) - ((sins at: j )* sisk).
	}.
		
	







]
