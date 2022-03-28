[Mesh]
  [gmg]
    type = GeneratedMeshGenerator
    dim = 3
    nx = 40
    xmax = 0.40
    ny = 40
    ymax = 0.40
    nz = 4
    zmax = 0.04
  []
 # Create blocks 0, 1, 2
  [block_1]   #delete
    type = SubdomainBoundingBoxGenerator
    input = gmg
    block_id = 1
    bottom_left = '0 0 0.02'
    top_right = '0.40 0.40 0.04'
  []
  [block_2]  #reyuan
    type = SubdomainBoundingBoxGenerator
    input = block_1
    block_id = 2
    bottom_left = '0.18 0.18 0.02'
    top_right = '0.22 0.22 0.04'
  []
  [./ed0]
     type = BlockDeletionGenerator
     input = block_2
      block = 1
  [../]


  # Create outer boundaries
  [boundary_left_0]
    type = SideSetsAroundSubdomainGenerator
    input = ed0
    block = 0
    normal = '-1 0 0'
    new_boundary = 'left_0'
  []
  [boundary_bot_0]
    type = SideSetsAroundSubdomainGenerator
    input = boundary_left_0
    block = 0
    normal = '0 0 -1'
    new_boundary = 'bot_0'
  []
  [boundary_right_0]
    type = SideSetsAroundSubdomainGenerator
    input = boundary_bot_0
    block = 0
    normal = '1 0 0'
    new_boundary = 'right_0'
  []
  [boundary_front_0]
    type = SideSetsAroundSubdomainGenerator
    input = boundary_right_0
    block = 0
    normal = '0 -1 0'
    new_boundary = 'front_0'
  []
  [boundary_back_0]
    type = SideSetsAroundSubdomainGenerator
    input = boundary_front_0
    block = 0
    normal = '0 1 0'
    new_boundary = 'back_0'
  []
  [boundary_top_2]
    type = SideSetsAroundSubdomainGenerator
    input = boundary_back_0
    block = 2
    normal = '0 0 1'
    new_boundary = 'top_2'
  []
  [boundary_left_2]
    type = SideSetsAroundSubdomainGenerator
    input = boundary_top_2
    block = 2
    normal = '-1 0 0'
    new_boundary = 'left_2'
  []
  [boundary_right_2]
    type = SideSetsAroundSubdomainGenerator
    input = boundary_left_2
    block = 2
    normal = '1 0 0'
    new_boundary = 'right_2'
  []
  [boundary_front_2]
    type = SideSetsAroundSubdomainGenerator
    input = boundary_right_2
    block = 2
    normal = '0 -1 0'
    new_boundary = 'front_2'
  []
  [boundary_back_2]
    type = SideSetsAroundSubdomainGenerator
    input = boundary_front_2
    block = 2
    normal = '0 1 0'
    new_boundary = 'back_2'
  []
   uniform_refine = 1
[]

[Variables]
   [T]
    block = '0 2'
    initial_condition = 293
  []
  [disp_x]
  []
  [disp_y]
  []
  [disp_z]
  []
[]

[Kernels]
  [hc_0]
    type = HeatConduction
    variable = T
    block ='0 2'
  []
  [TensorMechanics]
    displacements = 'disp_x disp_y disp_z'
  []
  [source_0]
    type = HeatSource
    variable = T
    function = volumetric_heat
    block =2
  []
[]

[Functions]
   [./volumetric_heat]
     type = ParsedFunction
     value = 9.375e6 #w/m3
     #i dont know why that volume heat source is 10e-2 of the right value
     #right value is 9.375e8
  [../]
[]


[AuxVariables]
  [./von_mises]
    #Dependent variable used to visualize the Von Mises stress
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[AuxKernels]
  [./von_mises_kernel]
    #Calculates the von mises stress and assigns it to von_mises
    type = RankTwoScalarAux
    variable = von_mises
    rank_two_tensor = stress
    execute_on = timestep_end
    scalar_type = VonMisesStress
  [../]
[]



[BCs]
   [bc_0]
    type = ConvectiveHeatFluxBC
    boundary = 'left_0 right_0 back_0 front_0'
    variable = T
    heat_transfer_coefficient =  5 # W/K/m^2
    T_infinity = 300.0
   []
   [bc_source_2]
     type = ConvectiveHeatFluxBC
     boundary = 'left_2 right_2 back_2 front_2 top_2'
     variable = T
     heat_transfer_coefficient = 5 # W/K/m^2
     T_infinity = 300.0
    []

  [./bc_cold_0]
    type = DirichletBC
    variable = T
    boundary = 'bot_0'
    value =293.0
  [../]

  [disp_x]
    type = DirichletBC
    variable = disp_x
    boundary = 'left_0'
    value = 0.0
  []
  [disp_y]
    type = DirichletBC
    variable = disp_y
    boundary = 'front_0'
    value = 0.0
  []
  [disp_z]
    type = DirichletBC
    variable = disp_z
    boundary = 'bot_0'
    value = 0.0
  []
[]

[Materials]
  [cond_2]#reyuan
    type = GenericConstantMaterial
    block = 2
    prop_names = thermal_conductivity
    prop_values = 54
  []
  [cond_0] #lengban
    type = GenericConstantMaterial
    block = 0
    prop_names = thermal_conductivity
    prop_values = 202.3
  []

  [elasticity_tensor_reyuan]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 8.85e10
    poissons_ratio = 0.31
    block = 2
  []

  [elasticity_tensor_lengban]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 7.1e10
    poissons_ratio = 0.33
    block = 0
  []


  [thermal_strain_reyuan]
    type = ComputeThermalExpansionEigenstrain
    thermal_expansion_coeff = 6.4e-6
    temperature = T
    stress_free_temperature = 298
    eigenstrain_name = eigenstrain_reyuan
    block = 2
  []
  [thermal_strain_lengban]
    type = ComputeThermalExpansionEigenstrain
    thermal_expansion_coeff = 2.3e-5
    temperature = T
    stress_free_temperature = 298
    eigenstrain_name = eigenstrain_lengban
    block = 0
  []


  [strain_reyuan]
    type = ComputeSmallStrain
    displacements = 'disp_x disp_y disp_z'
    eigenstrain_names = 'eigenstrain_reyuan'
    block = 2
  []
  [strain_lengban]
    type = ComputeSmallStrain
    displacements = 'disp_x disp_y disp_z'
    eigenstrain_names = 'eigenstrain_lengban'
    block = 0
  []
  [stress] #We use linear elasticity
    type = ComputeLinearElasticStress
  []

[]


[Executioner]
  type = Steady
  #automatic_scaling = true

  solve_type = 'PJFNK'
  petsc_options_iname = '-pc_type -pc_hypre_type -ksp_gmres_restart'
  petsc_options_value = 'hypre boomeramg 101'

  l_max_its = 30
  nl_max_its = 100
  nl_abs_tol = 1e-14
  l_tol = 1e-06
[]

[Preconditioning]
  [SMP]
    type = SMP
    full = true
  []
[]

[Outputs]
  file_base = reli9_out
  perf_graph = true
  exodus = true
  csv = false
[]
