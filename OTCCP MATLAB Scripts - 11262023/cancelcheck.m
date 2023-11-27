function cancelcheck()
global canceled

    if canceled == 1
        ME = MException('MATLAB:Canceled', 'Analysis was canceled.');
        throw(ME)
    end
end