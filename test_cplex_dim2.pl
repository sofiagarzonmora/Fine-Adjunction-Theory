import cplex
from cplex.exceptions import CplexError

def solve_simple_milp():
    # Create a Cplex problem instance
    prob = cplex.Cplex()
    
    # Set the problem type to maximization
    prob.set_problem_type(cplex.Cplex.problem_type.MILP)
    prob.objective.set_sense(prob.objective.sense.maximize)
    
    # Define the decision variable
    variables = ['x0','x1','x2','x3','x4','x5','x6','x7','x8','x9','x10','x11']
    variable_types = ['C','I','C','C','C','I','I','I','I','I','I','I']  # 'I' for integer variable
    lower_bounds = [0.0,-float('inf'),0.0, 0.0, 0.0,-float('inf'),-float('inf'),-float('inf'),-float('inf'),-float('inf'),-float('inf'),-float('inf')]    # upper bounds
    upper_bounds = [1.0,float('inf'),1.9,0.0,1.0,float('inf'),float('inf'),float('inf'),float('inf'),float('inf'),float('inf'),float('inf')]    # lower bounds
    
    # Add variable to the problem
    prob.variables.add(names=variables, types=variable_types, lb=lower_bounds, ub=upper_bounds)
    
    # Define the objective function (maximize x2)
    objective_coeffs = [0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]  # Coefficient for x2 in the objective
    prob.objective.set_linear(list(zip(variables, objective_coeffs)))

    # Define the constraints
    constraints = [
        [variables,[1.0,-1.0,-1.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0]],
	[variables,[0.0,0.0,-1.0,0.0,1.0,-1.0,0.0,0.0,0.0,0.0,0.0,0.0]],
	[variables,[-1.0,0.0,-1.0,0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0,0.0]],
	[variables,[-1.0,0.0,-1.0,0.0,-1.0,0.0,0.0,1.0,1.0,0.0,0.0,0.0]],
	[variables,[0.0,0.0,0.0,0.0,0.0,1.0,0.0,0.0,0.0,-1.0,0.0,0.0]],
	[variables,[0.0,1.0,0.0,0.0,0.0,0.0,-1.0,0.0,0.0,0.0,0.0,0.0]],
	[variables,[0.0,1.0,0.0,0.0,0.0,0.0,0.0,-1.0,-1.0,1.0,0.0,0.0]],
	[variables,[0.0,1.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,-1.0,0.0]],
	[variables,[0.0,0.0,0.0,0.0,0.0,0.0,-1.0,0.0,0.0,0.0,1.0,0.0]],
	[variables,[0.0,0.0,0.0,0.0,0.0,1.0,0.0,-1.0,-1.0,0.0,1.0,0.0]],
	[variables,[0.0,0.0,0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0,0.0,-1.0]],
	[variables,[0.0,0.0,0.0,0.0,0.0,0.0,1.0,-1.0,-1.0,0.0,0.0,1.0]],
	[variables,[0.0,1.0,0.0,0.0,0.0,0.0,0.0,0.0,-1.0,0.0,0.0,0.0]],
	[variables,[0.0,0.0,0.0,0.0,0.0,1.0,0.0,-1.0,0.0,0.0,0.0,0.0]],
	[variables,[0.0,0.0,0.0,0.0,0.0,0.0,-1.0,0.0,1.0,0.0,0.0,0.0]]
    ]
    rhs_values = [0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0]  # Right-hand side for the constraint
    constraint_senses = ['E','E','E','E','L','L','L','L','L','L','L','L','L','L','L']  # 'G' for greater-than (>=), 'L' for lower-than (<=)
    
    # Add the constraints to the problem
    prob.linear_constraints.add(
        lin_expr=constraints,
        senses=constraint_senses,
        rhs=rhs_values
    )


    # Print the model details
    print("\n--- Model Details ---")
    
    # Print the objective function
    obj_coeffs = prob.objective.get_linear()
    print("Objective: Maximize")
    print(" + ".join([f"{obj_coeffs[i]} * {variables[i]}" for i in range(len(variables))]))
    
   
    # Print variable bounds
    print("\nVariable Bounds:")
    for i, var in enumerate(variables):
        lb = prob.variables.get_lower_bounds(i)
        ub = prob.variables.get_upper_bounds(i)
        print(f"{var}: {lb} <= {var} <= {ub}")

  # Print the constraints
    num_constraints = prob.linear_constraints.get_num()
    print("\nConstraints:")
    for i in range(num_constraints):
        # Get the coefficients and variables for the constraint
        row = prob.linear_constraints.get_rows(i)
        indices = row.ind
        values = row.val
        
        # Format the constraint expression
        terms = [f"{values[j]} * {variables[indices[j]]}" for j in range(len(indices))]
        sense = prob.linear_constraints.get_senses(i)
        rhs = prob.linear_constraints.get_rhs(i)
        
        # Determine sense symbol
        if sense == 'G':
            sense_symbol = ">="
        elif sense == 'L':
            sense_symbol = "<="
        elif sense == 'E':
            sense_symbol = "="
        
        # Print the formatted constraint
        print(f"Constraint {i + 1}: {' + '.join(terms)} {sense_symbol} {rhs}")
    

    
    # Solve the MILP problem
    try:
        prob.solve()
        
        # Get the solution status
        solution_status = prob.solution.status[prob.solution.get_status()]
        print(f"Solution status: {solution_status}")
        
        # Get the optimal objective value
        print(f"Optimal objective value: {prob.solution.get_objective_value()}")
        
        # Get the value of the decision variable
        solution_values = prob.solution.get_values()
        for i, value in enumerate(solution_values):
            print(f"{variables[i]} = {value}")
    
    except CplexError as exc:
        print(exc)

# Solve the MILP problem
solve_simple_milp()
