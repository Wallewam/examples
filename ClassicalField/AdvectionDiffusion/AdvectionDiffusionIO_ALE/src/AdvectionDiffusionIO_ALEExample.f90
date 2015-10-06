!> \file
!> \author Chris Bradley
!> \brief This is an example program to solve an ALE formulation of the advection-diffusion equation using openCMISS calls.
!>
!> \section LICENSE
!>
!> Version: MPL 1.1/GPL 2.0/LGPL 2.1
!>
!> The contents of this file are subject to the Mozilla Public License
!> Version 1.1 (the "License"); you may not use this file except in
!> compliance with the License. You may obtain a copy of the License at
!> http://www.mozilla.org/MPL/
!>
!> Software distributed under the License is distributed on an "AS IS"
!> basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
!> License for the specific language governing rights and limitations
!> under the License.
!>
!> The Original Code is openCMISS
!>
!> The Initial Developer of the Original Code is University of Auckland,
!> Auckland, New Zealand and University of Oxford, Oxford, United
!> Kingdom. Portions created by the University of Auckland and University
!> of Oxford are Copyright (C) 2007 by the University of Auckland and
!> the University of Oxford. All Rights Reserved.
!>
!> Contributor(s):
!>
!> Alternatively, the contents of this file may be used under the terms of
!> either the GNU General Public License Version 2 or later (the "GPL"), or
!> the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
!> in which case the provisions of the GPL or the LGPL are applicable instead
!> of those above. If you wish to allow use of your version of this file only
!> under the terms of either the GPL or the LGPL, and not to allow others to
!> use your version of this file under the terms of the MPL, indicate your
!> decision by deleting the provisions above and replace them with the notice
!> and other provisions required by the GPL or the LGPL. If you do not delete
!> the provisions above, a recipient may use your version of this file under
!> the terms of any one of the MPL, the GPL or the LGPL.
!>

!> \example ClassicalField/AdvectionDiffusion/AdvectionDiffusionIO/src/AdvectionDiffusionIO_ALEExample.f90
!! Example program to solve a diffusion equation using openCMISS calls.
!! \par Latest Builds:
!! \li <a href='http://autotest.bioeng.auckland.ac.nz/opencmiss-build/logs_x86_64-linux/ClassicalField/Diffusion/build-intel'>Linux Intel Build</a>
!! \li <a href='http://autotest.bioeng.auckland.ac.nz/opencmiss-build/logs_x86_64-linux/ClassicalField/Diffusion/build-gnu'>Linux GNU Build</a>
!<

!> Main program
PROGRAM ADVECTIONDIFFUSIONIOALEEXAMPLE

  !
  !================================================================================================================================
  !

  !PROGRAM LIBRARIES

  USE OpenCMISS_Iron
  USE FLUID_MECHANICS_IO_ROUTINES
  USE MPI

#ifdef WIN32
  USE IFQWINCMISS
#endif

  !
  !================================================================================================================================
  !

  !PROGRAM VARIABLES AND TYPES

  IMPLICIT NONE

  !Test program parameters

  INTEGER(CMFEIntg), PARAMETER :: CoordinateSystemUserNumber=1
  INTEGER(CMFEIntg), PARAMETER :: RegionUserNumber=2
  INTEGER(CMFEIntg), PARAMETER :: BasisUserNumber=3
  INTEGER(CMFEIntg), PARAMETER :: GeneratedMeshUserNumber=4
  INTEGER(CMFEIntg), PARAMETER :: MeshUserNumber=5
  INTEGER(CMFEIntg), PARAMETER :: DecompositionUserNumber=6
  INTEGER(CMFEIntg), PARAMETER :: GeometricFieldUserNumber=7
  INTEGER(CMFEIntg), PARAMETER :: EquationsSetFieldUserNumber=1337
  INTEGER(CMFEIntg), PARAMETER :: DependentFieldUserNumberAdvecDiff=8
  INTEGER(CMFEIntg), PARAMETER :: MaterialsFieldUserNumberAdvecDiff=9
  INTEGER(CMFEIntg), PARAMETER :: EquationsSetUserNumberAdvecDiff=10
  INTEGER(CMFEIntg), PARAMETER :: ProblemUserNumber=11
  INTEGER(CMFEIntg), PARAMETER :: ControlLoopNode=0
  INTEGER(CMFEIntg), PARAMETER :: IndependentFieldUserNumberAdvecDiff=12
  !INTEGER(CMFEIntg), PARAMETER :: AnalyticFieldUserNumber=13
  INTEGER(CMFEIntg), PARAMETER :: SourceFieldUserNumberAdvecDiff=14
  INTEGER(CMFEIntg), PARAMETER :: DomainUserNumber=1

  !Program types

  TYPE(EXPORT_CONTAINER):: CM
  
  !Program variables

  INTEGER(CMFEIntg) :: NUMBER_OF_DIMENSIONS

  INTEGER(CMFEIntg) :: BASIS_TYPE
  INTEGER(CMFEIntg) :: BASIS_NUMBER_SPACE
  INTEGER(CMFEIntg) :: BASIS_NUMBER_CONCENTRATION
  INTEGER(CMFEIntg) :: BASIS_XI_GAUSS_SPACE
  INTEGER(CMFEIntg) :: BASIS_XI_GAUSS_CONCENTRATION
  INTEGER(CMFEIntg) :: BASIS_XI_INTERPOLATION_SPACE
  INTEGER(CMFEIntg) :: BASIS_XI_INTERPOLATION_CONCENTRATION
  INTEGER(CMFEIntg) :: MESH_NUMBER_OF_COMPONENTS
  INTEGER(CMFEIntg) :: MESH_COMPONENT_NUMBER_SPACE
  INTEGER(CMFEIntg) :: MESH_COMPONENT_NUMBER_CONCENTRATION
  INTEGER(CMFEIntg) :: NUMBER_OF_NODES_SPACE
  INTEGER(CMFEIntg) :: NUMBER_OF_NODES_CONCENTRATION
  INTEGER(CMFEIntg) :: NUMBER_OF_ELEMENT_NODES_SPACE
  INTEGER(CMFEIntg) :: NUMBER_OF_ELEMENT_NODES_CONCENTRATION
  INTEGER(CMFEIntg) :: TOTAL_NUMBER_OF_NODES
  INTEGER(CMFEIntg) :: TOTAL_NUMBER_OF_ELEMENTS
  INTEGER(CMFEIntg) :: MAXIMUM_ITERATIONS
  INTEGER(CMFEIntg) :: RESTART_VALUE
!  INTEGER(CMFEIntg) :: MPI_IERROR
  INTEGER(CMFEIntg) :: NUMBER_OF_FIXED_WALL_NODES_ADVECTION_DIFFUSION
  INTEGER(CMFEIntg) :: NUMBER_OF_INLET_WALL_NODES_ADVECTION_DIFFUSION

  INTEGER(CMFEIntg) :: EQUATIONS_ADVECTION_DIFFUSION_OUTPUT
  INTEGER(CMFEIntg) :: COMPONENT_NUMBER
  INTEGER(CMFEIntg) :: NODE_NUMBER
  INTEGER(CMFEIntg) :: ELEMENT_NUMBER
  INTEGER(CMFEIntg) :: NODE_COUNTER
  INTEGER(CMFEIntg) :: CONDITION

  INTEGER(CMFEIntg) :: LINEAR_SOLVER_ADVECTION_DIFFUSION_OUTPUT_TYPE

  INTEGER, ALLOCATABLE, DIMENSION(:):: FIXED_WALL_NODES_ADVECTION_DIFFUSION
  INTEGER, ALLOCATABLE, DIMENSION(:):: INLET_WALL_NODES_ADVECTION_DIFFUSION

  REAL(CMFEDP) :: INITIAL_FIELD_ADVECTION_DIFFUSION(3)
  REAL(CMFEDP) :: BOUNDARY_CONDITIONS_ADVECTION_DIFFUSION(3)
  REAL(CMFEDP) :: DIVERGENCE_TOLERANCE
  REAL(CMFEDP) :: RELATIVE_TOLERANCE
  REAL(CMFEDP) :: ABSOLUTE_TOLERANCE
  REAL(CMFEDP) :: LINESEARCH_ALPHA
  REAL(CMFEDP) :: VALUE
  REAL(CMFEDP) :: DIFF_COEFF_PARAM_ADVECTION_DIFFUSION(3)

  LOGICAL :: EXPORT_FIELD_IO
  LOGICAL :: LINEAR_SOLVER_ADVECTION_DIFFUSION_DIRECT_FLAG
  LOGICAL :: FIXED_WALL_NODES_ADVECTION_DIFFUSION_FLAG
  LOGICAL :: INLET_WALL_NODES_ADVECTION_DIFFUSION_FLAG

  !CMISS variables

  !Regions
  TYPE(cmfe_RegionType) :: Region
  TYPE(cmfe_RegionType) :: WorldRegion
  !Coordinate systems
  TYPE(cmfe_CoordinateSystemType) :: CoordinateSystem
  TYPE(cmfe_CoordinateSystemType) :: WorldCoordinateSystem
  !Basis
  TYPE(cmfe_BasisType) :: BasisSpace
  TYPE(cmfe_BasisType) :: BasisConcentration
  !Nodes
  TYPE(cmfe_NodesType) :: Nodes
  !Elements
  TYPE(cmfe_MeshElementsType) :: MeshElementsSpace
  TYPE(cmfe_MeshElementsType) :: MeshElementsConcentration
  !Meshes
  TYPE(cmfe_MeshType) :: Mesh
  !Decompositions
  TYPE(cmfe_DecompositionType) :: Decomposition
  !Fields
  TYPE(cmfe_FieldsType) :: Fields
  !Field types
  TYPE(cmfe_FieldType) :: GeometricField
  TYPE(cmfe_FieldType) :: EquationsSetField
  TYPE(cmfe_FieldType) :: DependentFieldAdvecDiff
  TYPE(cmfe_FieldType) :: MaterialsFieldAdvecDiff
  TYPE(cmfe_FieldType) :: IndependentFieldAdvecDiff
  TYPE(cmfe_FieldType) :: SourceFieldAdvecDiff
  !Boundary conditions
  TYPE(cmfe_BoundaryConditionsType) :: BoundaryConditionsAdvecDiff
  !Equations sets
  TYPE(cmfe_EquationsSetType) :: EquationsSetAdvecDiff
  !Equations
  TYPE(cmfe_EquationsType) :: EquationsAdvecDiff
  !Problems
  TYPE(cmfe_ProblemType) :: Problem
  !Control loops
  TYPE(cmfe_ControlLoopType) :: ControlLoop
  !Solvers
  TYPE(cmfe_SolverType) :: SolverAdvecDiff, LinearSolverAdvecDiff
  !Solver equations
  TYPE(cmfe_SolverEquationsType) :: SolverEquationsAdvecDiff


#ifdef WIN32
  !Quickwin type
  LOGICAL :: QUICKWIN_STATUS=.FALSE.
  TYPE(WINDOWCONFIG) :: QUICKWIN_WINDOW_CONFIG
#endif
  
  !Generic CMISS variables
  
  INTEGER(CMFEIntg) :: EquationsSetIndex
  INTEGER(CMFEIntg) :: Err
  
#ifdef WIN32
  !Initialise QuickWin
  QUICKWIN_WINDOW_CONFIG%TITLE="General Output" !Window title
  QUICKWIN_WINDOW_CONFIG%NUMTEXTROWS=-1 !Max possible number of rows
  QUICKWIN_WINDOW_CONFIG%MODE=QWIN$SCROLLDOWN
  !Set the window parameters
  QUICKWIN_STATUS=SETWINDOWCONFIG(QUICKWIN_WINDOW_CONFIG)
  !If attempt fails set with system estimated values
  IF(.NOT.QUICKWIN_STATUS) QUICKWIN_STATUS=SETWINDOWCONFIG(QUICKWIN_WINDOW_CONFIG)
#endif

  !
  !================================================================================================================================
  !

  !INITIALISE OPENCMISS

  CALL cmfe_Initialise(WorldCoordinateSystem,WorldRegion,Err)

  !
  !================================================================================================================================
  !

  !PROBLEM CONTROL PANEL

  !Import cmHeart mesh information
  CALL FLUID_MECHANICS_IO_READ_CMHEART(CM,Err)  
  BASIS_NUMBER_SPACE=CM%ID_M
  BASIS_NUMBER_CONCENTRATION=CM%ID_V
  NUMBER_OF_DIMENSIONS=CM%D
  BASIS_TYPE=CM%IT_T
  BASIS_XI_INTERPOLATION_SPACE=CM%IT_M
  BASIS_XI_INTERPOLATION_CONCENTRATION=CM%IT_V
  NUMBER_OF_NODES_SPACE=CM%N_M
  NUMBER_OF_NODES_CONCENTRATION=CM%N_V
  TOTAL_NUMBER_OF_NODES=CM%N_T
  TOTAL_NUMBER_OF_ELEMENTS=CM%E_T
  NUMBER_OF_ELEMENT_NODES_SPACE=CM%EN_M
  NUMBER_OF_ELEMENT_NODES_CONCENTRATION=CM%EN_V
  !Set initial values
  INITIAL_FIELD_ADVECTION_DIFFUSION(1)=0.0_CMFEDP
  INITIAL_FIELD_ADVECTION_DIFFUSION(2)=0.0_CMFEDP
  INITIAL_FIELD_ADVECTION_DIFFUSION(3)=0.0_CMFEDP
  !Set boundary conditions - what condition should be applied?
  !Set boundary conditions
  FIXED_WALL_NODES_ADVECTION_DIFFUSION_FLAG=.FALSE.
  INLET_WALL_NODES_ADVECTION_DIFFUSION_FLAG=.TRUE.
  IF(FIXED_WALL_NODES_ADVECTION_DIFFUSION_FLAG) THEN
    NUMBER_OF_FIXED_WALL_NODES_ADVECTION_DIFFUSION=1
    ALLOCATE(FIXED_WALL_NODES_ADVECTION_DIFFUSION(NUMBER_OF_FIXED_WALL_NODES_ADVECTION_DIFFUSION))
    FIXED_WALL_NODES_ADVECTION_DIFFUSION=(/42/)
  ENDIF
  IF(INLET_WALL_NODES_ADVECTION_DIFFUSION_FLAG) THEN
    NUMBER_OF_INLET_WALL_NODES_ADVECTION_DIFFUSION=105
    ALLOCATE(INLET_WALL_NODES_ADVECTION_DIFFUSION(NUMBER_OF_INLET_WALL_NODES_ADVECTION_DIFFUSION))
    INLET_WALL_NODES_ADVECTION_DIFFUSION=(/4,11,12,13,29,33,34,35,47,51,52,53,69,71,83,87,88,89,100,102,103,104,112,114,115, & 
    & 116,126,128,137,141,142,143,154,156,157,158,166,168,169,170,180,182,191,195,196,197,208,210,211, & 
    & 212,220,222,223,224,234,236,245,249,250,251,262,264,265,266,274,276,277,278,288,290,299,303,304, & 
    & 305,316,318,319,320,328,330,331,332,342,344,353,357,358,359,370,372,373,374,382,384,385,386,396, & 
    & 398,411,412,426,427,438,439,450/)

    !Set initial boundary conditions
    BOUNDARY_CONDITIONS_ADVECTION_DIFFUSION(1)=42.0_CMFEDP
    BOUNDARY_CONDITIONS_ADVECTION_DIFFUSION(2)=0.0_CMFEDP
    BOUNDARY_CONDITIONS_ADVECTION_DIFFUSION(3)=0.0_CMFEDP
  ENDIF  !Set material parameters
  DIFF_COEFF_PARAM_ADVECTION_DIFFUSION(1)=1.0_CMFEDP
  DIFF_COEFF_PARAM_ADVECTION_DIFFUSION(2)=1.0_CMFEDP
  DIFF_COEFF_PARAM_ADVECTION_DIFFUSION(3)=1.0_CMFEDP
  !Set interpolation parameters
  BASIS_XI_GAUSS_SPACE=3
  BASIS_XI_GAUSS_CONCENTRATION=3
  !Set output parameter
  !(NoOutput/ProgressOutput/TimingOutput/SolverOutput/SolverMatrixOutput)
  LINEAR_SOLVER_ADVECTION_DIFFUSION_OUTPUT_TYPE=CMFE_SOLVER_NO_OUTPUT
  !(NoOutput/TimingOutput/MatrixOutput/ElementOutput)
  EQUATIONS_ADVECTION_DIFFUSION_OUTPUT=CMFE_EQUATIONS_NO_OUTPUT
  !Set solver parameters
  LINEAR_SOLVER_ADVECTION_DIFFUSION_DIRECT_FLAG=.FALSE.
  RELATIVE_TOLERANCE=1.0E-10_CMFEDP !default: 1.0E-05_CMFEDP
  ABSOLUTE_TOLERANCE=1.0E-10_CMFEDP !default: 1.0E-10_CMFEDP
  DIVERGENCE_TOLERANCE=1.0E20 !default: 1.0E5
  MAXIMUM_ITERATIONS=100000 !default: 100000
  RESTART_VALUE=3000 !default: 30
  LINESEARCH_ALPHA=1.0

  !
  !================================================================================================================================
  !

  !COORDINATE SYSTEM

  !Start the creation of a new RC coordinate system
  CALL cmfe_CoordinateSystem_Initialise(CoordinateSystem,Err)
  CALL cmfe_CoordinateSystem_CreateStart(CoordinateSystemUserNumber,CoordinateSystem,Err)
  !Set the coordinate system dimension
  CALL cmfe_CoordinateSystem_DimensionSet(CoordinateSystem,NUMBER_OF_DIMENSIONS,Err)
  !Finish the creation of the coordinate system
  CALL cmfe_CoordinateSystem_CreateFinish(CoordinateSystem,Err)

  !
  !================================================================================================================================
  !

  !REGION

  !Start the creation of a new region
  CALL cmfe_Region_Initialise(Region,Err)
  CALL cmfe_Region_CreateStart(RegionUserNumber,WorldRegion,Region,Err)
  !Set the regions coordinate system as defined above
  CALL cmfe_Region_CoordinateSystemSet(Region,CoordinateSystem,Err)
  !Finish the creation of the region
  CALL cmfe_Region_CreateFinish(Region,Err)

  !
  !================================================================================================================================
  !

  !BASES

  !Start the creation of new bases
  MESH_NUMBER_OF_COMPONENTS=1
  CALL cmfe_Basis_Initialise(BasisSpace,Err)
  CALL cmfe_Basis_CreateStart(BASIS_NUMBER_SPACE,BasisSpace,Err)
  !Set the basis type (Lagrange/Simplex)
  CALL cmfe_Basis_TypeSet(BasisSpace,BASIS_TYPE,Err)
  !Set the basis xi number
  CALL cmfe_Basis_NumberOfXiSet(BasisSpace,NUMBER_OF_DIMENSIONS,Err)
  !Set the basis xi interpolation and number of Gauss points
  IF(NUMBER_OF_DIMENSIONS==2) THEN
    CALL cmfe_Basis_InterpolationXiSet(BasisSpace,(/BASIS_XI_INTERPOLATION_SPACE,BASIS_XI_INTERPOLATION_SPACE/),Err)
    CALL cmfe_Basis_QuadratureNumberOfGaussXiSet(BasisSpace,(/BASIS_XI_GAUSS_SPACE,BASIS_XI_GAUSS_SPACE/),Err)
  ELSE IF(NUMBER_OF_DIMENSIONS==3) THEN
    CALL cmfe_Basis_InterpolationXiSet(BasisSpace,(/BASIS_XI_INTERPOLATION_SPACE,BASIS_XI_INTERPOLATION_SPACE, & 
      & BASIS_XI_INTERPOLATION_SPACE/),Err)                         
    CALL cmfe_Basis_QuadratureNumberOfGaussXiSet(BasisSpace,(/BASIS_XI_GAUSS_SPACE,BASIS_XI_GAUSS_SPACE,BASIS_XI_GAUSS_SPACE/),Err)
  ENDIF
  !Finish the creation of the basis
  CALL cmfe_Basis_CreateFinish(BasisSpace,Err)
  !Start the creation of another basis
  IF(BASIS_XI_INTERPOLATION_CONCENTRATION==BASIS_XI_INTERPOLATION_SPACE) THEN
    BasisConcentration=BasisSpace
  ELSE
    MESH_NUMBER_OF_COMPONENTS=MESH_NUMBER_OF_COMPONENTS+1
    !Initialise a new pressure basis
    CALL cmfe_Basis_Initialise(BasisConcentration,Err)
    !Start the creation of a basis
    CALL cmfe_Basis_CreateStart(BASIS_NUMBER_CONCENTRATION,BasisConcentration,Err)
    !Set the basis type (Lagrange/Simplex)
    CALL cmfe_Basis_TypeSet(BasisConcentration,BASIS_TYPE,Err)
    !Set the basis xi number
    CALL cmfe_Basis_NumberOfXiSet(BasisConcentration,NUMBER_OF_DIMENSIONS,Err)
    !Set the basis xi interpolation and number of Gauss points
    IF(NUMBER_OF_DIMENSIONS==2) THEN
      CALL cmfe_Basis_InterpolationXiSet(BasisConcentration,(/BASIS_XI_INTERPOLATION_CONCENTRATION, &
        & BASIS_XI_INTERPOLATION_CONCENTRATION/),Err)
      CALL cmfe_Basis_QuadratureNumberOfGaussXiSet(BasisConcentration,(/BASIS_XI_GAUSS_CONCENTRATION, &
        & BASIS_XI_GAUSS_CONCENTRATION/),Err)
    ELSE IF(NUMBER_OF_DIMENSIONS==3) THEN
      CALL cmfe_Basis_InterpolationXiSet(BasisConcentration,(/BASIS_XI_INTERPOLATION_CONCENTRATION, & 
        & BASIS_XI_INTERPOLATION_CONCENTRATION, BASIS_XI_INTERPOLATION_CONCENTRATION/),Err)                         
      CALL cmfe_Basis_QuadratureNumberOfGaussXiSet(BasisConcentration,(/BASIS_XI_GAUSS_CONCENTRATION, & 
        & BASIS_XI_GAUSS_CONCENTRATION, BASIS_XI_GAUSS_CONCENTRATION/),Err)
    ENDIF
    !Finish the creation of the basis
    CALL cmfe_Basis_CreateFinish(BasisConcentration,Err)
  ENDIF
  !
  !================================================================================================================================
  !

  !MESH

  !Start the creation of mesh nodes
  CALL cmfe_Nodes_Initialise(Nodes,Err)
  CALL cmfe_Mesh_Initialise(Mesh,Err)
  CALL cmfe_Nodes_CreateStart(Region,TOTAL_NUMBER_OF_NODES,Nodes,Err)
  CALL cmfe_Nodes_CreateFinish(Nodes,Err)
  !Start the creation of the mesh
  CALL cmfe_Mesh_CreateStart(MeshUserNumber,Region,NUMBER_OF_DIMENSIONS,Mesh,Err)
  !Set number of mesh elements
  CALL cmfe_Mesh_NumberOfElementsSet(Mesh,TOTAL_NUMBER_OF_ELEMENTS,Err)
  !Set number of mesh components
  CALL cmfe_Mesh_NumberOfComponentsSet(Mesh,MESH_NUMBER_OF_COMPONENTS,Err)
  !Specify spatial mesh component
  CALL cmfe_MeshElements_Initialise(MeshElementsSpace,Err)
  CALL cmfe_MeshElements_Initialise(MeshElementsConcentration,Err)
  MESH_COMPONENT_NUMBER_SPACE=1
  MESH_COMPONENT_NUMBER_CONCENTRATION=1
  CALL cmfe_MeshElements_CreateStart(Mesh,MESH_COMPONENT_NUMBER_SPACE,BasisSpace,MeshElementsSpace,Err)
  DO ELEMENT_NUMBER=1,TOTAL_NUMBER_OF_ELEMENTS
    CALL cmfe_MeshElements_NodesSet(MeshElementsSpace,ELEMENT_NUMBER,CM%M(ELEMENT_NUMBER,1:NUMBER_OF_ELEMENT_NODES_SPACE),Err)
  ENDDO
  CALL cmfe_MeshElements_CreateFinish(MeshElementsSpace,Err)
  !Specify pressure mesh component
  IF(BASIS_XI_INTERPOLATION_CONCENTRATION==BASIS_XI_INTERPOLATION_SPACE) THEN
    MeshElementsConcentration=MeshElementsSpace
    MESH_COMPONENT_NUMBER_CONCENTRATION=MESH_COMPONENT_NUMBER_SPACE
  ELSE
    MESH_COMPONENT_NUMBER_CONCENTRATION=MESH_COMPONENT_NUMBER_SPACE+1
    CALL cmfe_MeshElements_CreateStart(Mesh,MESH_COMPONENT_NUMBER_CONCENTRATION,BasisConcentration,MeshElementsConcentration,Err)
    DO ELEMENT_NUMBER=1,TOTAL_NUMBER_OF_ELEMENTS
      CALL cmfe_MeshElements_NodesSet(MeshElementsConcentration,ELEMENT_NUMBER,CM%V(ELEMENT_NUMBER, & 
        & 1:NUMBER_OF_ELEMENT_NODES_CONCENTRATION),Err)
    ENDDO
    CALL cmfe_MeshElements_CreateFinish(MeshElementsConcentration,Err)
  ENDIF
  !Finish the creation of the mesh
  CALL cmfe_Mesh_CreateFinish(Mesh,Err)

  !
  !================================================================================================================================
  !

  !GEOMETRIC FIELD

  !Create a decomposition
  CALL cmfe_Decomposition_Initialise(Decomposition,Err)
  CALL cmfe_Decomposition_CreateStart(DecompositionUserNumber,Mesh,Decomposition,Err)
  !Set the decomposition to be a general decomposition with the specified number of domains
  CALL cmfe_Decomposition_TypeSet(Decomposition,CMFE_DECOMPOSITION_CALCULATED_TYPE,Err)
  CALL cmfe_Decomposition_NumberOfDomainsSet(Decomposition,DomainUserNumber,Err)
  !Finish the decomposition
  CALL cmfe_Decomposition_CreateFinish(Decomposition,Err)

  !Start to create a default (geometric) field on the region
  CALL cmfe_Field_Initialise(GeometricField,Err)
  CALL cmfe_Field_CreateStart(GeometricFieldUserNumber,Region,GeometricField,Err)
  !Set the field type
  CALL cmfe_Field_TypeSet(GeometricField,CMFE_FIELD_GEOMETRIC_TYPE,Err)
  !Set the decomposition to use
  CALL cmfe_Field_MeshDecompositionSet(GeometricField,Decomposition,Err)
  !Set the scaling to use
  CALL cmfe_Field_ScalingTypeSet(GeometricField,CMFE_FIELD_NO_SCALING,Err)
  !Set the mesh component to be used by the field components.
  DO COMPONENT_NUMBER=1,NUMBER_OF_DIMENSIONS
    CALL cmfe_Field_ComponentMeshComponentSet(GeometricField,CMFE_FIELD_U_VARIABLE_TYPE,COMPONENT_NUMBER, & 
      & MESH_COMPONENT_NUMBER_SPACE,Err)
  ENDDO
  !Finish creating the field
  CALL cmfe_Field_CreateFinish(GeometricField,Err)
  !Update the geometric field parameters
  DO NODE_NUMBER=1,NUMBER_OF_NODES_SPACE
    DO COMPONENT_NUMBER=1,NUMBER_OF_DIMENSIONS
      VALUE=CM%N(NODE_NUMBER,COMPONENT_NUMBER)
      CALL cmfe_Field_ParameterSetUpdateNode(GeometricField,CMFE_FIELD_U_VARIABLE_TYPE,CMFE_FIELD_VALUES_SET_TYPE,1, & 
        & CMFE_NO_GLOBAL_DERIV,NODE_NUMBER,COMPONENT_NUMBER,VALUE,Err)
    ENDDO
  ENDDO
  CALL cmfe_Field_ParameterSetUpdateStart(GeometricField,CMFE_FIELD_U_VARIABLE_TYPE,CMFE_FIELD_VALUES_SET_TYPE,Err)
  CALL cmfe_Field_ParameterSetUpdateFinish(GeometricField,CMFE_FIELD_U_VARIABLE_TYPE,CMFE_FIELD_VALUES_SET_TYPE,Err)

  !
  !================================================================================================================================
  !

  !EQUATIONS SETS
 
  !Create the equations_set
  CALL cmfe_EquationsSet_Initialise(EquationsSetAdvecDiff,Err)
    CALL cmfe_Field_Initialise(EquationsSetField,Err)
  CALL cmfe_EquationsSet_CreateStart(EquationsSetUserNumberAdvecDiff,Region,GeometricField, &
    & [CMFE_EQUATIONS_SET_CLASSICAL_FIELD_CLASS,CMFE_EQUATIONS_SET_ADVECTION_DIFFUSION_EQUATION_TYPE, &
    & CMFE_EQUATIONS_SET_NO_SOURCE_ALE_ADVECTION_DIFFUSION_SUBTYPE],EquationsSetFieldUserNumber,EquationsSetField, &
    & EquationsSetAdvecDiff,Err)
  !Set the equations set to be a standard Laplace problem
  !Finish creating the equations set
  CALL cmfe_EquationsSet_CreateFinish(EquationsSetAdvecDiff,Err)

  !
  !================================================================================================================================
  !

  !DEPENDENT FIELDS

  !Create the equations set dependent field variables
  CALL cmfe_Field_Initialise(DependentFieldAdvecDiff,Err)
  CALL cmfe_EquationsSet_DependentCreateStart(EquationsSetAdvecDiff,DependentFieldUserNumberAdvecDiff,DependentFieldAdvecDiff,Err)
  !Finish the equations set dependent field variables
  CALL cmfe_EquationsSet_DependentCreateFinish(EquationsSetAdvecDiff,Err)

  !
  !================================================================================================================================
  !

  !MATERIALS FIELDS

  !Create the equations set material field variables
  CALL cmfe_Field_Initialise(MaterialsFieldAdvecDiff,Err)
  CALL cmfe_EquationsSet_MaterialsCreateStart(EquationsSetAdvecDiff,MaterialsFieldUserNumberAdvecDiff,MaterialsFieldAdvecDiff,Err)
  !Finish the equations set dependent field variables
  CALL cmfe_EquationsSet_MaterialsCreateFinish(EquationsSetAdvecDiff,Err)

  !
  !================================================================================================================================
  !

  !SOURCE FIELDS


  !Create the equations set source field variables
!   CALL cmfe_Field_Initialise(SourceFieldAdvecDiff,Err)
!   CALL cmfe_EquationsSet_SourceCreateStart(EquationsSetAdvecDiff,SourceFieldUserNumberAdvecDiff,SourceFieldAdvecDiff,Err)
!   CALL cmfe_Field_ComponentInterpolationSet(SourceFieldAdvecDiff,CMFE_FIELD_U_VARIABLE_TYPE,1,CMFE_FIELD_NODE_BASED_INTERPOLATION,Err)
!   !Finish the equations set dependent field variables
!   CALL cmfe_EquationsSet_SourceCreateFinish(EquationsSetAdvecDiff,Err)


  !
  !================================================================================================================================
  !

  !INDEPENDENT FIELDS

 ! CALL cmfe_Field_ParameterSetDataGet(GeometricField,CMFE_FIELD_U_VARIABLE_TYPE,CMFE_FIELD_VALUES_SET_TYPE,GEOMETRIC_PARAMETERS,Err)


  !Create the equations set independent field variables
  CALL cmfe_Field_Initialise(IndependentFieldAdvecDiff,Err)
  CALL cmfe_EquationsSet_IndependentCreateStart(EquationsSetAdvecDiff,IndependentFieldUserNumberAdvecDiff, &
    & IndependentFieldAdvecDiff,Err)
!   IF(NUMBER_GLOBAL_Z_ELEMENTS==0) THEN
!   CALL cmfe_Field_ComponentInterpolationSet(IndependentField,CMFE_FIELD_U_VARIABLE_TYPE,1,CMFE_FIELD_NODE_BASED_INTERPOLATION,Err) 
!   CALL cmfe_Field_ComponentInterpolationSet(IndependentField,CMFE_FIELD_U_VARIABLE_TYPE,2,CMFE_FIELD_NODE_BASED_INTERPOLATION,Err)
!   ENDIF
  !Set the mesh component to be used by the field components.
  CALL cmfe_Field_ComponentMeshComponentSet(IndependentFieldAdvecDiff,CMFE_FIELD_U_VARIABLE_TYPE,MESH_COMPONENT_NUMBER_SPACE, & 
    & MESH_COMPONENT_NUMBER_CONCENTRATION,Err)

  !Finish the equations set dependent field variables
  CALL cmfe_EquationsSet_IndependentCreateFinish(EquationsSetAdvecDiff,Err)
 
  !
  !================================================================================================================================
  !


  !EQUATIONS


  !Create the equations set equations
  CALL cmfe_Equations_Initialise(EquationsAdvecDiff,Err)
  CALL cmfe_EquationsSet_EquationsCreateStart(EquationsSetAdvecDiff,EquationsAdvecDiff,Err)
  !Set the equations matrices sparsity type
  CALL cmfe_Equations_SparsityTypeSet(EquationsAdvecDiff,CMFE_EQUATIONS_SPARSE_MATRICES,Err)
  !Set the equations set output
  CALL cmfe_Equations_OutputTypeSet(EquationsAdvecDiff,EQUATIONS_ADVECTION_DIFFUSION_OUTPUT,Err)
  !CALL cmfe_Equations_OutputTypeSet(Equations,CMFE_EQUATIONS_NO_OUTPUT,Err)
  !CALL cmfe_Equations_OutputTypeSet(Equations,CMFE_EQUATIONS_TIMING_OUTPUT,Err)
  !CALL cmfe_Equations_OutputTypeSet(Equations,CMFE_EQUATIONS_MATRIX_OUTPUT,Err)
  !CALL cmfe_Equations_OutputTypeSet(Equations,CMFE_EQUATIONS_ELEMENT_MATRIX_OUTPUT,Err)
  !Finish the equations set equations
  CALL cmfe_EquationsSet_EquationsCreateFinish(EquationsSetAdvecDiff,Err)

  !
  !================================================================================================================================
  !

  !Start the creation of a problem.
  CALL cmfe_Problem_Initialise(Problem,Err)
  CALL cmfe_ControlLoop_Initialise(ControlLoop,Err)
  CALL cmfe_Problem_CreateStart(ProblemUserNumber,[CMFE_PROBLEM_CLASSICAL_FIELD_CLASS, &
    & CMFE_PROBLEM_ADVECTION_DIFFUSION_EQUATION_TYPE,CMFE_PROBLEM_NO_SOURCE_ALE_ADVECTION_DIFFUSION_SUBTYPE],Problem,Err)
  !Finish the creation of a problem.
  CALL cmfe_Problem_CreateFinish(Problem,Err)
  !Start the creation of the problem control loop
  CALL cmfe_Problem_ControlLoopCreateStart(Problem,Err)
  !Get the control loop
  CALL cmfe_Problem_ControlLoopGet(Problem,ControlLoopNode,ControlLoop,Err)
  !Set the times
  CALL cmfe_ControlLoop_TimesSet(ControlLoop,0.0_CMFEDP,3.0_CMFEDP,0.1_CMFEDP,Err)
  !Finish creating the problem control loop
  CALL cmfe_Problem_ControlLoopCreateFinish(Problem,Err)

  !
  !================================================================================================================================
  !


  !SOLVERS

  !Start the creation of the problem solvers
!  
! !   !For the Direct Solver MUMPS, uncomment the below two lines and comment out the above five
! !   CALL SOLVER_LINEAR_TYPE_SET(LINEAR_SOLVER,SOLVER_LINEAR_DIRECT_SOLVE_TYPE,ERR,ERROR,*999)
! !   CALL SOLVER_LINEAR_DIRECT_TYPE_SET(LINEAR_SOLVER,SOLVER_DIRECT_MUMPS,ERR,ERROR,*999) 
! 

  CALL cmfe_Solver_Initialise(SolverAdvecDiff,Err)
  CALL cmfe_Solver_Initialise(LinearSolverAdvecDiff,Err)
  CALL cmfe_Problem_SolversCreateStart(Problem,Err)
  CALL cmfe_Problem_SolverGet(Problem,CMFE_CONTROL_LOOP_NODE,1,SolverAdvecDiff,Err)
  !CALL cmfe_Solver_OutputTypeSet(Solver,CMFE_SOLVER_NO_OUTPUT,Err)
  !CALL cmfe_Solver_OutputTypeSet(Solver,CMFE_SOLVER_PROGRESS_OUTPUT,Err)
  !CALL cmfe_Solver_OutputTypeSet(Solver,CMFE_SOLVER_TIMING_OUTPUT,Err)
  !CALL cmfe_Solver_OutputTypeSet(Solver,CMFE_SOLVER_SOLVER_OUTPUT,Err)
  CALL cmfe_Solver_OutputTypeSet(SolverAdvecDiff,CMFE_SOLVER_PROGRESS_OUTPUT,Err)
  CALL cmfe_Solver_DynamicLinearSolverGet(SolverAdvecDiff,LinearSolverAdvecDiff,Err)
  CALL cmfe_Solver_LinearIterativeMaximumIterationsSet(LinearSolverAdvecDiff,300,Err)
  !Finish the creation of the problem solver
  CALL cmfe_Problem_SolversCreateFinish(Problem,Err)

  !
  !================================================================================================================================
  !
  !SOLVER EQUATIONS

  !Create the problem solver equations
  CALL cmfe_Solver_Initialise(SolverAdvecDiff,Err)
  CALL cmfe_SolverEquations_Initialise(SolverEquationsAdvecDiff,Err)
  CALL cmfe_Problem_SolverEquationsCreateStart(Problem,Err)
  !Get the solve equations
  CALL cmfe_Problem_SolverGet(Problem,CMFE_CONTROL_LOOP_NODE,1,SolverAdvecDiff,Err)
  CALL cmfe_Solver_SolverEquationsGet(SolverAdvecDiff,SolverEquationsAdvecDiff,Err)
  !Set the solver equations sparsity
  CALL cmfe_SolverEquations_SparsityTypeSet(SolverEquationsAdvecDiff,CMFE_SOLVER_SPARSE_MATRICES,Err)
  !CALL cmfe_SolverEquations_SparsityTypeSet(SolverEquations,CMFE_SOLVER_FULL_MATRICES,Err)  
  !Add in the equations set
  CALL cmfe_SolverEquations_EquationsSetAdd(SolverEquationsAdvecDiff,EquationsSetAdvecDiff,EquationsSetIndex,Err)
  !Finish the creation of the problem solver equations
  CALL cmfe_Problem_SolverEquationsCreateFinish(Problem,Err)

  !
  !================================================================================================================================
  !

 !BOUNDARY CONDITIONS

  !Start the creation of the equations set boundary conditions for Poisson
  CALL cmfe_BoundaryConditions_Initialise(BoundaryConditionsAdvecDiff,Err)
  CALL cmfe_SolverEquations_BoundaryConditionsCreateStart(SolverEquationsAdvecDiff,BoundaryConditionsAdvecDiff,Err)
  !Set fixed wall nodes
  IF(FIXED_WALL_NODES_ADVECTION_DIFFUSION_FLAG) THEN
    DO NODE_COUNTER=1,NUMBER_OF_FIXED_WALL_NODES_ADVECTION_DIFFUSION
      NODE_NUMBER=FIXED_WALL_NODES_ADVECTION_DIFFUSION(NODE_COUNTER)
      CONDITION=CMFE_BOUNDARY_CONDITION_FIXED
!       DO COMPONENT_NUMBER=1,NUMBER_OF_DIMENSIONS
        VALUE=0.0_CMFEDP
        CALL cmfe_BoundaryConditions_SetNode(BoundaryConditionsAdvecDiff,DependentFieldAdvecDiff,CMFE_FIELD_U_VARIABLE_TYPE, &
          & CMFE_NO_GLOBAL_DERIV,1, &
          & NODE_NUMBER,MESH_COMPONENT_NUMBER_CONCENTRATION,CONDITION,VALUE,Err)
!       ENDDO
    ENDDO
  ENDIF
  !Set velocity boundary conditions
  IF(INLET_WALL_NODES_ADVECTION_DIFFUSION_FLAG) THEN
    DO NODE_COUNTER=1,NUMBER_OF_INLET_WALL_NODES_ADVECTION_DIFFUSION
      NODE_NUMBER=INLET_WALL_NODES_ADVECTION_DIFFUSION(NODE_COUNTER)
      CONDITION=CMFE_BOUNDARY_CONDITION_FIXED
!       DO COMPONENT_NUMBER=1,NUMBER_OF_DIMENSIONS
        VALUE=0.1_CMFEDP
        CALL cmfe_BoundaryConditions_SetNode(BoundaryConditionsAdvecDiff,DependentFieldAdvecDiff,CMFE_FIELD_U_VARIABLE_TYPE, &
          & CMFE_NO_GLOBAL_DERIV,1, &
          & NODE_NUMBER,MESH_COMPONENT_NUMBER_CONCENTRATION,CONDITION,VALUE,Err)
!       ENDDO
    ENDDO
  ENDIF
  !Finish the creation of the equations set boundary conditions
  CALL cmfe_SolverEquations_BoundaryConditionsCreateFinish(SolverEquationsAdvecDiff,Err)

  !
  !================================================================================================================================
  !

  !RUN SOLVERS

  !Turn of PETSc error handling
  !CALL PETSC_ERRORHANDLING_SET_ON(ERR,ERROR,*999)

  !Solve the problem
  WRITE(*,'(A)') "Solving problem..."
  CALL cmfe_Problem_Solve(Problem,Err)
  WRITE(*,'(A)') "Problem solved!"

  !
  !================================================================================================================================
  !

  !OUTPUT

  EXPORT_FIELD_IO=.TRUE.
  IF(EXPORT_FIELD_IO) THEN
    WRITE(*,'(A)') "Exporting fields..."
    CALL cmfe_Fields_Initialise(Fields,Err)
    CALL cmfe_Fields_Create(Region,Fields,Err)
    CALL cmfe_Fields_NodesExport(Fields,"AdvectionDiffusionIO_ALE","FORTRAN",Err)
    CALL cmfe_Fields_ElementsExport(Fields,"AdvectionDiffusionIO_ALE","FORTRAN",Err)
    CALL cmfe_Fields_Finalise(Fields,Err)
    WRITE(*,'(A)') "Field exported!"
  ENDIF
  

  !Finialise CMISS
  !CALL cmfe_Finalise(Err)

  WRITE(*,'(A)') "Program successfully completed."
  
  STOP

END PROGRAM ADVECTIONDIFFUSIONIOALEEXAMPLE
