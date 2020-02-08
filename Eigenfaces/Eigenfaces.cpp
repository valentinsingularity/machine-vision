#include "opencv2/core/core.hpp"
#include "opencv2/contrib/contrib.hpp"
#include "opencv2/highgui/highgui.hpp"

#include <iostream>
#include <fstream>
#include <sstream>

using namespace cv;
using namespace std;

static Mat norm_0_255(InputArray _src) {
	Mat src = _src.getMat();
	Mat dst;
	switch (src.channels()) {
	case 1:
		cv::normalize(_src, dst, 0, 255, NORM_MINMAX, CV_8UC1);
		break;
	case 3:
		cv::normalize(_src, dst, 0, 255, NORM_MINMAX, CV_8UC3);
		break;
	default:
		src.copyTo(dst);
		break;
	}
	return dst;
}

static void read_csv(const string& filename, vector<Mat>& images, vector<int>& labels, char separator = ';') {
	std::ifstream file(filename.c_str(), ifstream::in);
	if (!file) {
		string error_message = "No valid input file was given, please check the given filename.";
		CV_Error(CV_StsBadArg, error_message);
	}
	string line, path, classlabel;
	while (getline(file, line)) {
		stringstream liness(line);
		getline(liness, path, separator);
		getline(liness, classlabel);
		if (!path.empty() && !classlabel.empty()) {
			images.push_back(imread(path, 0));
			labels.push_back(atoi(classlabel.c_str()));
		}
	}
}

int main(int argc, const char *argv[]) {

	if (argc < 2) {
		cout << "usage: " << argv[0] << " <csv.ext> <output_folder> " << endl;
		exit(1);
	}
	string output_folder = ".";
	if (argc == 3) {
		output_folder = string(argv[2]);
	}

	string fn_csv = string(argv[1]);
	
	vector<Mat> images;
	vector<int> labels;
	
	try {
		read_csv(fn_csv, images, labels);
	}
	catch (cv::Exception& e) {
		cerr << "Error opening file \"" << fn_csv << "\". Reason: " << e.msg << endl;
		exit(1);
	}
	
	if (images.size() <= 1) {
		string error_message = "This demo needs at least 2 images to work. Please add more images to your data set!";
		CV_Error(CV_StsError, error_message);
	}
	
	int height = images[0].rows;
	
	Mat testSample = images[images.size()-1];
	int testLabel = labels[labels.size()-1];
	for (int i = 0; i <= (images.size() - 1); i++) cout << labels[i] << endl;
	images.pop_back();
	labels.pop_back();


	Ptr<FaceRecognizer> model = createEigenFaceRecognizer(18);  //keep 18 eigenfaces
	model->train(images, labels);
	
	int predictedLabel = model->predict(testSample);
	
	string result_message = format("Predicted class = %d / Actual class = %d.", predictedLabel, testLabel);
	cout << result_message << endl;
	
	Mat eigenvalues = model->getMat("eigenvalues");
	
	Mat W = model->getMat("eigenvectors");
	
	Mat mean = model->getMat("mean");

	int num_components = 18;
	Mat evs, projection, reconstruction;

	imshow("Yoda", testSample);

	waitKey(0);

    evs = Mat(W, Range::all(), Range(0, num_components));
	projection = subspaceProject(evs, mean, testSample.reshape(1, 1));
    reconstruction = subspaceReconstruct(evs, mean, projection);
	reconstruction = norm_0_255(reconstruction.reshape(1, testSample.rows));
	imshow("Yoda_reconstructed", reconstruction);

	waitKey(0);

	int img_number;

	for (int i = 0;; i++)
	{
		if (predictedLabel == labels[i])
		{
			img_number = i;
			break;
		}
	}
	

	evs = Mat(W, Range::all(), Range(0, num_components));
	projection = subspaceProject(evs, mean, images[img_number].reshape(1, 1));
	reconstruction = subspaceReconstruct(evs, mean, projection);
	reconstruction = norm_0_255(reconstruction.reshape(1, images[img_number].rows));
	imshow(format("Reconstruction of most similar person", num_components), reconstruction);

	waitKey(0);

	imshow("Most similar person", images[img_number]);

	waitKey(0);

	return 0;
}