classdef iEdgeDetector < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure        matlab.ui.Figure
        TopPanel        matlab.ui.container.Panel
        AppTitleLabel   matlab.ui.control.Label
        ControlPanel    matlab.ui.container.Panel
        UploadImageButton matlab.ui.control.Button
        ApplyButton     matlab.ui.control.Button
        ResetButton     matlab.ui.control.Button
        WatermarkLabel  matlab.ui.control.Label
        ImageGridPanel  matlab.ui.container.Panel
        OriginalAxes    matlab.ui.control.UIAxes
        SobelAxes       matlab.ui.control.UIAxes
        CannyAxes       matlab.ui.control.UIAxes
        PrewittAxes     matlab.ui.control.UIAxes
        OriginalImage   % To store the uploaded image data
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: UploadImageButton
        function UploadImageButtonPushed(app, ~)
            % Open file explorer to select an image
            [file, path] = uigetfile({'*.jpg;*.jpeg;*.png;*.bmp', ...
                'Image Files (*.jpg, *.png, *.bmp)'});

            % Handle user cancellation safely
            if isequal(file, 0)
                return;
            end

            try
                % Read and store the image
                img = imread(fullfile(path, file));
                app.OriginalImage = img;

                % Display original image in the top-left axes
                imshow(img, 'Parent', app.OriginalAxes);
                app.OriginalAxes.Title.String = 'Original Image';

                % Clear old results if any
                cla(app.SobelAxes);
                app.SobelAxes.Title.String = 'Sobel Discovery';
                cla(app.CannyAxes);
                app.CannyAxes.Title.String = 'Canny Edge Discovery';
                cla(app.PrewittAxes);
                app.PrewittAxes.Title.String = 'Prewitt / Awaiting Results';

            catch ME
                uialert(app.UIFigure, ...
                    'Error loading image. Please try another file.', 'Error');
            end
        end

        % Button pushed function: ApplyButton
        function ApplyButtonPushed(app, ~)
            % Error handling: Alert if no image is uploaded
            if isempty(app.OriginalImage)
                uialert(app.UIFigure, 'Please upload an image first!', ...
                    'Missing Image');
                return;
            end

            % Auto-convert to grayscale if it is an RGB image
            img = app.OriginalImage;
            if size(img, 3) == 3
                grayImg = rgb2gray(img);
            else
                grayImg = img;
            end

            % Apply Gaussian smoothing before detection
            smoothedImg = imgaussfilt(grayImg, 1.5);

            % Apply and display Sobel Edge Detection
            sobelEdges = edge(smoothedImg, 'sobel');
            imshow(sobelEdges, 'Parent', app.SobelAxes);
            app.SobelAxes.Title.String = 'Sobel Discovery';

            % Apply and display Canny Edge Detection
            cannyEdges = edge(smoothedImg, 'canny');
            imshow(cannyEdges, 'Parent', app.CannyAxes);
            app.CannyAxes.Title.String = 'Canny Edge Discovery';

            % Apply and display Prewitt Edge Detection
            prewittEdges = edge(smoothedImg, 'prewitt');
            imshow(prewittEdges, 'Parent', app.PrewittAxes);
            app.PrewittAxes.Title.String = 'Prewitt Edge Detection';
        end

        % Button pushed function: ResetButton
        function ResetButtonPushed(app, ~)
            % Clear stored image memory
            app.OriginalImage = [];

            % Clear all visual axes
            cla(app.OriginalAxes);
            cla(app.SobelAxes);
            cla(app.CannyAxes);
            cla(app.PrewittAxes);

            % Reset titles
            app.OriginalAxes.Title.String = 'Original Source';
            app.SobelAxes.Title.String = 'Sobel Discovery';
            app.CannyAxes.Title.String = 'Canny Edge Discovery';
            app.PrewittAxes.Title.String = 'Prewitt / Awaiting Results';
        end

    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 1000 700];
            app.UIFigure.Name = 'iEdge Dashboard';
            app.UIFigure.Color = '#0F111A';

            % Create TopPanel
            app.TopPanel = uipanel(app.UIFigure);
            app.TopPanel.Position = [10 630 980 60];
            app.TopPanel.BackgroundColor = '#1C1E2A';
            app.TopPanel.BorderType = 'none';

            % Create AppTitleLabel
            app.AppTitleLabel = uilabel(app.TopPanel);
            app.AppTitleLabel.Position = [20 15 200 30];
            app.AppTitleLabel.FontName = 'Arial';
            app.AppTitleLabel.FontSize = 24;
            app.AppTitleLabel.FontWeight = 'bold';
            app.AppTitleLabel.FontColor = '#FFFFFF';
            app.AppTitleLabel.Text = 'iEdge Dashboard';

            % Create ControlPanel
            app.ControlPanel = uipanel(app.UIFigure);
            app.ControlPanel.Position = [10 30 280 590];
            app.ControlPanel.BackgroundColor = '#1C1E2A';
            app.ControlPanel.BorderType = 'none';
            app.ControlPanel.Title = 'Control Panel';
            app.ControlPanel.TitlePosition = 'centertop';
            app.ControlPanel.ForegroundColor = '#FFFFFF';
            app.ControlPanel.FontName = 'Arial';
            app.ControlPanel.FontWeight = 'bold';
            app.ControlPanel.FontSize = 14;

            % Create UploadImageButton
            app.UploadImageButton = uibutton(app.ControlPanel, 'push');
            app.UploadImageButton.ButtonPushedFcn = ...
                createCallbackFcn(app, @UploadImageButtonPushed, true);
            app.UploadImageButton.BackgroundColor = '#2A2D3A';
            app.UploadImageButton.FontColor = '#FFFFFF';
            app.UploadImageButton.Position = [40 500 200 40];
            app.UploadImageButton.Text = 'Upload Image';

            % Create ApplyButton
            app.ApplyButton = uibutton(app.ControlPanel, 'push');
            app.ApplyButton.ButtonPushedFcn = ...
                createCallbackFcn(app, @ApplyButtonPushed, true);
            app.ApplyButton.BackgroundColor = '#FF3366';
            app.ApplyButton.FontColor = '#FFFFFF';
            app.ApplyButton.FontWeight = 'bold';
            app.ApplyButton.Position = [40 440 200 40];
            app.ApplyButton.Text = '+ Apply Detection';

            % Create ResetButton
            app.ResetButton = uibutton(app.ControlPanel, 'push');
            app.ResetButton.ButtonPushedFcn = ...
                createCallbackFcn(app, @ResetButtonPushed, true);
            app.ResetButton.BackgroundColor = '#2A2D3A';
            app.ResetButton.FontColor = '#FFFFFF';
            app.ResetButton.Position = [40 380 200 40];
            app.ResetButton.Text = 'Reset';

            % Create ImageGridPanel
            app.ImageGridPanel = uipanel(app.UIFigure);
            app.ImageGridPanel.Position = [300 30 690 590];
            app.ImageGridPanel.BackgroundColor = '#0F111A';
            app.ImageGridPanel.BorderType = 'none';

            % Create OriginalAxes
            app.OriginalAxes = uiaxes(app.ImageGridPanel);
            app.OriginalAxes.Position = [10 300 330 280];
            app.OriginalAxes.XColor = 'none';
            app.OriginalAxes.YColor = 'none';
            app.OriginalAxes.Title.String = 'Original Source';
            app.OriginalAxes.Title.Color = '#FFFFFF';
            app.OriginalAxes.Color = 'none';

            % Create SobelAxes
            app.SobelAxes = uiaxes(app.ImageGridPanel);
            app.SobelAxes.Position = [350 300 330 280];
            app.SobelAxes.XColor = 'none';
            app.SobelAxes.YColor = 'none';
            app.SobelAxes.Title.String = 'Sobel Discovery';
            app.SobelAxes.Title.Color = '#FFFFFF';
            app.SobelAxes.Color = 'none';

            % Create CannyAxes
            app.CannyAxes = uiaxes(app.ImageGridPanel);
            app.CannyAxes.Position = [10 10 330 280];
            app.CannyAxes.XColor = 'none';
            app.CannyAxes.YColor = 'none';
            app.CannyAxes.Title.String = 'Canny Edge Discovery';
            app.CannyAxes.Title.Color = '#FFFFFF';
            app.CannyAxes.Color = 'none';

            % Create PrewittAxes
            app.PrewittAxes = uiaxes(app.ImageGridPanel);
            app.PrewittAxes.Position = [350 10 330 280];
            app.PrewittAxes.XColor = 'none';
            app.PrewittAxes.YColor = 'none';
            app.PrewittAxes.Title.String = 'Prewitt / Awaiting Results';
            app.PrewittAxes.Title.Color = '#FFFFFF';
            app.PrewittAxes.Color = 'none';

            % Create WatermarkLabel
            app.WatermarkLabel = uilabel(app.UIFigure);
            app.WatermarkLabel.Position = [800 5 180 20];
            app.WatermarkLabel.FontColor = '#A0A0A0';
            app.WatermarkLabel.Text = 'Made by Hadi aymen';
            app.WatermarkLabel.HorizontalAlignment = 'right';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = iEdgeDetector()
            createComponents(app);
            registerApp(app, app.UIFigure);
            if nargout == 0
                clear app;
            end
        end

        % Code that executes before app deletion
        function delete(app)
            delete(app.UIFigure);
        end
    end
end