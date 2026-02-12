% linear_algebra.m
% Advanced linear algebra operations
%
% Run with: mlab++ linear_algebra.m --visual

disp('MatLabC++ Linear Algebra Demo');
disp('==============================');
disp('');

% ========== MATRIX DECOMPOSITIONS ==========
disp('1. Matrix Decompositions');
disp('------------------------');

A = [4, 1, 2; 1, 5, 3; 2, 3, 6];
disp('Original matrix A:');
disp(A);
disp('');

% LU decomposition
[L, U, P] = lu(A);
fprintf('LU Decomposition:\n');
fprintf('  L (lower): %dx%d\n', size(L));
fprintf('  U (upper): %dx%d\n', size(U));
fprintf('  Verification: ||PA - LU|| = %.2e\n', norm(P*A - L*U));
disp('');

% QR decomposition
[Q, R] = qr(A);
fprintf('QR Decomposition:\n');
fprintf('  Q (orthogonal): %dx%d\n', size(Q));
fprintf('  R (upper triangular): %dx%d\n', size(R));
fprintf('  Verification: ||A - QR|| = %.2e\n', norm(A - Q*R));
disp('');

% Singular Value Decomposition
[U, S, V] = svd(A);
fprintf('SVD: A = U*S*V''\n');
fprintf('  Singular values: [%.3f, %.3f, %.3f]\n', diag(S));
fprintf('  Condition number: %.2f\n', cond(A));
disp('');

% ========== EIGENVALUE PROBLEMS ==========
disp('2. Eigenvalue Problems');
disp('----------------------');

[V_eig, D_eig] = eig(A);
eigenvalues = diag(D_eig);
fprintf('Eigenvalues: [%.3f, %.3f, %.3f]\n', eigenvalues);
fprintf('Spectral radius: %.3f\n', max(abs(eigenvalues)));
fprintf('Trace: %.3f (sum of eigenvalues)\n', trace(A));
fprintf('Determinant: %.3f (product of eigenvalues)\n', det(A));
disp('');

% ========== SOLVING LINEAR SYSTEMS ==========
disp('3. Solving Linear Systems');
disp('-------------------------');

b = [1; 2; 3];
fprintf('Solving Ax = b:\n');

% Direct solve
x_direct = A \ b;
fprintf('  Direct solution: x = [%.3f, %.3f, %.3f]''\n', x_direct);
fprintf('  Residual: ||Ax - b|| = %.2e\n', norm(A*x_direct - b));
disp('');

% Iterative solve (for larger systems)
x0 = zeros(3, 1);
[x_iter, flag, relres, iter] = pcg(A, b, 1e-6, 100, [], [], x0);
fprintf('  Iterative solution (PCG):\n');
fprintf('    Iterations: %d\n', iter);
fprintf('    Relative residual: %.2e\n', relres);
disp('');

% ========== MATRIX NORMS ==========
disp('4. Matrix Norms');
disp('---------------');

fprintf('Frobenius norm: %.3f\n', norm(A, 'fro'));
fprintf('1-norm: %.3f\n', norm(A, 1));
fprintf('2-norm (spectral): %.3f\n', norm(A, 2));
fprintf('Infinity norm: %.3f\n', norm(A, inf));
disp('');

% ========== RANK AND NULLSPACE ==========
disp('5. Rank and Nullspace');
disp('---------------------');

fprintf('Rank of A: %d\n', rank(A));
fprintf('Nullity: %d\n', size(null(A), 2));
fprintf('Dimension: %dx%d\n', size(A));
disp('');

% Rank-deficient matrix example
B = [1, 2, 3; 2, 4, 6; 3, 6, 9];
fprintf('Rank-deficient matrix B:\n');
disp(B);
fprintf('  Rank: %d (should be 1)\n', rank(B));
N = null(B);
if ~isempty(N)
    fprintf('  Nullspace dimension: %d\n', size(N, 2));
end
disp('');

% ========== LEAST SQUARES ==========
disp('6. Least Squares Fitting');
disp('------------------------');

% Overdetermined system: more equations than unknowns
A_over = rand(10, 3);
b_over = rand(10, 1);

x_ls = A_over \ b_over;  % Least squares solution
residual = A_over * x_ls - b_over;
fprintf('Overdetermined system: %dx%d\n', size(A_over));
fprintf('  Solution norm: %.3f\n', norm(x_ls));
fprintf('  Residual norm: %.3f\n', norm(residual));
disp('');

% ========== MATRIX POWERS ==========
disp('7. Matrix Powers and Exponentiation');
disp('-----------------------------------');

fprintf('A^2 norm: %.3f\n', norm(A^2));
fprintf('A^10 norm: %.3f\n', norm(A^10));

% Matrix exponential
expA = expm(A);
fprintf('exp(A) norm: %.3f\n', norm(expA));
disp('');

disp('Demo complete! Linear algebra features:');
disp('  ✓ LU, QR, SVD decompositions');
disp('  ✓ Eigenvalue/eigenvector computation');
disp('  ✓ Direct and iterative solvers');
disp('  ✓ Matrix norms and condition numbers');
disp('  ✓ Rank, nullspace, least squares');
disp('  ✓ Matrix functions (powers, exponentials)');
disp('');