M = load_sequence('./gjbLookAtTargets','small_', 1, 10, 4, 'jpg');
DG = buildDGmatrix(M);
bg = biograph(DG)
view(bg)
