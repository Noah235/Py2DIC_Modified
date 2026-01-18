% === Batch Image Processor GUI (Apply identical crop + ROI on pairs) ===

function BatchDIC_GUI()

    % Create GUI
    fig = uifigure('Name','Batch Image Processor','Position',[100 100 400 200]);
    gl = uigridlayout(fig, [3,1]);

    % Folder selection button
    btnFolder = uibutton(gl, 'push', 'Text', 'Choose Folder', 'ButtonPushedFcn', @chooseFolder);

    % Run batch process button, initially disabled
    btnRun = uibutton(gl, 'push', 'Text', 'Run Batch Process', 'Enable', 'off', 'ButtonPushedFcn', @runBatch);

    % Status label
    lblStatus = uilabel(gl, 'Text', 'Select a folder to begin.', 'HorizontalAlignment', 'center');

    folderPath = '';

    % Callback: Choose folder
    function chooseFolder(~, ~)
        path = uigetdir;
        if path ~= 0
            folderPath = path;
            btnRun.Enable = 'on';
            lblStatus.Text = ['Selected: ', folderPath];
        end
    end

    % Callback: Run batch process
    function runBatch(~, ~)
        lblStatus.Text = 'Processing...'; 
        drawnow;

        exts = {'*.jpg','*.jpeg','*.png','*.tif'};
        files = [];
        for e = 1:length(exts)
            files = [files; dir(fullfile(folderPath, exts{e}))];
        end

        procFolder = fullfile(folderPath, 'processed'); 
        if ~exist(procFolder, 'dir'), mkdir(procFolder); end

        % Get undeformed files
        undeformedFiles = files(contains(lower({files.name}), 'undeformed'));

    for k = 1:length(undeformedFiles)
    namePart = regexprep(undeformedFiles(k).name, '(?i)undeformed[_-]?', '');
    refFile = fullfile(folderPath, undeformedFiles(k).name);
    ref = imread(refFile);

    % Get all matching deformed files for this undeformed image
    defMatches = {};
    for j = 1:length(files)
        fname = lower(files(j).name);
        if contains(fname, lower(namePart)) && contains(fname, 'deformed')
            defMatches{end+1} = fullfile(folderPath, files(j).name); %#ok<AGROW>
        end
    end

    % If no match found, skip
    if isempty(defMatches)
        warning('No matching deformed image for %s', undeformedFiles(k).name);
        continue;
    end

    % On undeformed image - get crop + ROI mask once
    [refCroppedMasked, bbox, roiMask] = manualCropWithROIDetailed(ref);

    % Save undeformed processed image
    refOut = fullfile(procFolder, undeformedFiles(k).name);
    imwrite(refCroppedMasked, refOut);

    % Now process all matching deformed images identically
    for m = 1:length(defMatches)
        defPath = defMatches{m};
        [~, defName, defExt] = fileparts(defPath);
        defImg = imread(defPath);

        defCropped = imcrop(defImg, bbox);

        if size(defCropped,3) == 3 % RGB
            for c = 1:3
                ch = defCropped(:,:,c);
                ch(~roiMask) = 255;
                defCropped(:,:,c) = ch;
            end
        else
            defCropped(~roiMask) = 255;
        end
        
        defOut = fullfile(procFolder, [defName defExt]);
        imwrite(defCropped, defOut);
    end

    lblStatus.Text = ['Done: ', undeformedFiles(k).name];
    drawnow;
end


        lblStatus.Text = 'Batch processing completed!';
    end

end

% Modified crop + ROI masking returning mask
function [croppedMasked, bbox, mask] = manualCropWithROIDetailed(img)
    % Draw crop rectangle
    hFig = figure('Name', 'Draw crop box', 'NumberTitle', 'off');
    imshow(img);
    title('Draw a box and double-click to confirm');
    hRect = imrect;
    rectPos = wait(hRect);
    close(hFig);

    bbox = round(rectPos);
    croppedImg = imcrop(img, bbox);

    % Draw polygon ROI on cropped image
    hFig = figure('Name', 'Draw ROI polygon', 'NumberTitle', 'off');
    imshow(croppedImg);
    title('Draw ROI polygon, double-click to confirm');
    hPoly = impoly;
    roiPos = wait(hPoly);
    close(hFig);

    % Create ROI mask (polygon inside)
    mask = poly2mask(roiPos(:,1), roiPos(:,2), size(croppedImg,1), size(croppedImg,2));

    % Set pixels outside ROI to 255 (white)
    if size(croppedImg,3) == 3  % RGB image
        for c = 1:3
            channel = croppedImg(:,:,c);
            channel(~mask) = 255;
            croppedImg(:,:,c) = channel;
        end
    else  % Grayscale image
        croppedImg(~mask) = 255;
    end

    croppedMasked = croppedImg;
end
