package main

import (
	"context"
	"fmt"
	"log"
	"os"

	vinipolysdk "github.com/vinipoly-drm/vinipoly-sdk/sdk/go"
)

func main() {
	apiKey := os.Getenv("VINIPOLY_API_KEY")
	if apiKey == "" {
		apiKey = "VP_your_api_key_here"
	}

	client, err := vinipolysdk.NewClient(vinipolysdk.Config{
		APIKey: apiKey,
	})
	if err != nil {
		log.Fatal(err)
	}

	info, err := client.GetAccountInfo(context.Background())
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf("Plan: %s | Quota: %d | Status: %s\n", info.Plan, info.Quota, info.Status)
}
