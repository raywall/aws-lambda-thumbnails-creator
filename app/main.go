package main

import (
	"context"
	"fmt"
	"image"
	"image/jpeg"
	"log"
	"os"
	"path/filepath"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3"
	"github.com/nfnt/resize"
)

// S3 provides the API operation methods for making requests to
// Amazon Simple Storage Service.
var svc *s3.S3

// called first, init will prepare a session and the client that
// we will use to connect to s3 service
func init() {
	config := aws.Config{Region: aws.String(os.Getenv("REGION"))}

	sess, err := session.NewSession(&config)
	if err != nil {
		log.Fatalf("failed creating a new aws session: %v", err)
	}

	svc = s3.New(sess)
}

// handler function will be used by the lambda to receive and process
// the s3 event received with the information about the object created
func handler(ctx context.Context, event events.S3Event) {
	if len(event.Records) > 0 {
		for _, record := range event.Records {
			bucket := record.S3.Bucket.Name
			key := record.S3.Object.Key

			// retrieve the image from s3 bucket
			result, err := svc.GetObject(&s3.GetObjectInput{
				Bucket: aws.String(bucket),
				Key:    aws.String(key),
			})
			if err != nil {
				fmt.Printf("failed retrieving image from s3 bucket: %v", err)
				os.Exit(1)
			}

			// decoding and adjusting image type
			img, _, err := image.Decode(result.Body)
			if err != nil {
				fmt.Printf("failed decoding and adjusting the image type: %v", err)
				os.Exit(1)
			}

			// image resize
			resizedImg := resize.Resize(100, 0, img, resize.Lanczos3)

			// save thumbnail on s3 bucket
			thumbKey := "thumbs/" + filepath.Base(key)
			output, err := os.Create("/tmp/temp-image")
			if err != nil {
				fmt.Printf("failed saving thumbnail: %v", err)
				os.Exit(1)
			}
			defer output.Close()

			jpeg.Encode(output, resizedImg, nil)

			_, err = svc.PutObject(&s3.PutObjectInput{
				Bucket: aws.String(bucket),
				Key:    aws.String(thumbKey),
				Body:   output,
			})
			if err != nil {
				fmt.Println(err)
				os.Exit(1)
			}
		}
	}
}

// main function will be refered as a handler of the lambda, and inside this function you will se
// a lambda start takes a handler and talks to an internal Lambda endpoint to pass requests to the handler.
func main() {
	lambda.Start(handler)
}
