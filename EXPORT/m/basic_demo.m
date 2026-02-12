% basic_demo.m
% Basic MatLabC++ functionality demonstration
%
% Run with: mlab++ basic_demo.m --visual

% Display welcome message
disp('MatLabC++ Basic Demo');
disp('====================');
disp('');

% Basic matrix operations
A = [1, 2, 3; 4, 5, 6; 7, 8, 9];
disp('Matrix A:');
disp(A);

% Matrix operations
disp('Transpose of A:');
disp(A');

% Determinant
det_A = det(A);
fprintf('Determinant of A: %.2f\n', det_A);

% Eigenvalues
eigenvals = eig(A);
disp('Eigenvalues of A:');
disp(eigenvals);

% Vector operations
v = [1; 2; 3];
disp('Vector v:');
disp(v);

% Norm
v_norm = norm(v);
fprintf('Norm of v: %.4f\n', v_norm);

% Element-wise operations
squared = A.^2;
disp('A squared (element-wise):');
disp(squared);

disp('');
disp('Demo complete!');
